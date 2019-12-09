track_number = 2

if track_number <= reaper.CountTracks(0) then

    track = reaper.GetTrack(0, track_number - 1)  -- tracks start with 0
    reaper.SetMediaTrackInfo_Value(track, "D_VOL", 1.0)  -- setting volume value to 0dB
    MIDI_channel = 11
    CC = 10 + track_number  -- ranging from 11 to 18
    CC_value = 91
    reaper.StuffMIDIMessage(
        18,  -- external device 2; 16 is external device 0, 17 is external device 1, etc.
        0xB0 + (MIDI_channel - 1),  -- this will send a CC message to the selected MIDI channel
        CC,
        CC_value
    )

end
