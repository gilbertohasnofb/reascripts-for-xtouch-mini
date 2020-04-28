function dBFromVal(val)
    return 20 * math.log(val, 10)
end


function ValFromdB(dB_val)
    return 10 ^ (dB_val / 20)
end


function sync_knobs()
    for track_number = 1, reaper.CountTracks(0) do
        if track_number <= 8 then
            track = reaper.GetTrack(0, track_number - 1)

            -- ========================================================================
            -- syncing pan

            pan = reaper.GetMediaTrackInfo_Value(track, "D_PAN")
            MIDI_channel = 11
            CC = track_number  -- ranging from 1 to 8
            CC_value = math.floor(((pan + 1.0) / 2.0) * 128)
            if (CC_value == 128) then
                CC_value = 127
            end
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),
                CC,
                CC_value
            )

            -- ========================================================================
            -- syncing volume

            vol = reaper.GetMediaTrackInfo_Value(track, "D_VOL")
            vol_dB = dBFromVal(vol)
            MIDI_channel = 11
            CC = 10 + track_number  -- ranging from 11 to 18
            CC_value = 0
            if vol_dB >= 0 then
                CC_value = math.floor((vol_dB * 3) + 91)
            else
                if vol_dB >= -200 then
                    CC_value = math.floor(-0.78 + 92.01 / (2^(vol_dB / -20.17)))
                else
                    CC_value = 0
                end
            end
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),
                CC,
                CC_value
            )

        end
    end
end
   
   
function reset_empty_track_knobs() 
    for track_number = reaper.CountTracks(0) + 1, 8 do
        if track_number <= 8 then

            -- ========================================================================
            -- resetting pan of empty track
        
            MIDI_channel = 11
            CC = track_number  -- ranging from 1 to 8
            CC_value = 64
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),
                CC,
                CC_value
            )
            

            -- ========================================================================
            -- resetting volume of empty track
            
            MIDI_channel = 11
            CC = 10 + track_number  -- ranging from 11 to 18
            CC_value = 0
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),
                CC,
                CC_value
            )
        end
    end
end


function sync_toggles()
    for track_number = 1, reaper.CountTracks(0) do
        if track_number <= 8 then
            track = reaper.GetTrack(0, track_number - 1)

            -- ========================================================================
            -- syncing ARMs

            MIDI_channel = 11
            CC = 18 + track_number  -- ranging from 19 to 26
            if reaper.GetMediaTrackInfo_Value(track, "I_RECARM") == 0 then
                CC_value = 0
            else
                CC_value = 127
            end
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
                CC,
                CC_value
            )

            -- ========================================================================
            -- syncing SOLOs

            MIDI_channel = 11
            CC = 26 + track_number  -- ranging from 27 to 34
            if reaper.GetMediaTrackInfo_Value(track, "I_SOLO") == 0 then
                CC_value = 0
            else
                CC_value = 127
            end
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
                CC,
                CC_value
            )

            -- ========================================================================
            -- syncing MUTEs

            MIDI_channel = 11
            CC = 34 + track_number  -- ranging from 35 to 42
            if reaper.GetMediaTrackInfo_Value(track, "B_MUTE") == 0 then
                CC_value = 0
            else
                CC_value = 127
            end
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
                CC,
                CC_value
            )
            
        end
    end
end
   

function reset_empty_track_toggles() 
    for track_number = reaper.CountTracks(0) + 1, 8 do
        if track_number <= 8 then
        
            -- ========================================================================
            -- resetting ARM button of empty track

            MIDI_channel = 11
            CC = 18 + track_number  -- ranging from 19 to 26
            CC_value = 0
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
                CC,
                CC_value
            )

            -- ========================================================================
            -- resetting SOLO button of empty track

            MIDI_channel = 11
            CC = 26 + track_number  -- ranging from 27 to 34
            CC_value = 0
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
                CC,
                CC_value
            )

            -- ========================================================================
            -- resetting MUTE button of empty track

            MIDI_channel = 11
            CC = 34 + track_number  -- ranging from 35 to 42
            CC_value = 0
            reaper.StuffMIDIMessage(
                18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
                0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
                CC,
                CC_value
            )
        end
    end
    
end


function sync_transport()

    local play_state = reaper.GetPlayState()  -- get transport state
    local playing = play_state == 1  -- is play button on
    local recording = play_state == 5  -- is record button on
    local looping = reaper.GetSetRepeat(-1) == 1  -- is loop/repeat button on

    -- ========================================================================
    -- syncing PLAY button

    if playing or recording then
        CC_value = 127
    else
        CC_value = 0
    end
    MIDI_channel = 11
    CC = 102
    reaper.StuffMIDIMessage(
        18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
        0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
        CC,
        CC_value
    )

    -- ========================================================================
    -- syncing REC button

    if recording then
        CC_value = 127
    else
        CC_value = 0
    end
    MIDI_channel = 11
    CC = 103
    reaper.StuffMIDIMessage(
        18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
        0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
        CC,
        CC_value
    )

    -- ========================================================================
    -- syncing LOOP button

    if looping then
        CC_value = 127
    else
        CC_value = 0
    end
    MIDI_channel = 11
    CC = 100
    reaper.StuffMIDIMessage(
        18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
        0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
        CC,
        CC_value
    )

end


function main()
    current_time = reaper.time_precise()
    if current_time - last_time >= 0.1 then  -- syncing toggles every 100ms
        sync_toggles()
        reset_empty_track_toggles() 
        sync_transport()
        last_time = current_time
        counter = counter + 1
    end
    if counter >= 8 then  -- syncing knobs every 0.8s
        sync_knobs()
        reset_empty_track_knobs()
        counter = 0
    end
    reaper.defer(main)
end


last_time = 0.0
counter = 0
main()
