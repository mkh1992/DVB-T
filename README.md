# DVB-T
implementation of ETSI EN 300 744 (Digital Video Broadcasting - terrestrial) in Matlab

only non-hierarchical mode is supported

input sample Rate should be (64/7)MSpS for 8MHz channel - 8MSpS for 7MHz channel and (48/7)MspS for 6MHz channels, one can use attached 

files for acquiring signal with USRP

a user friendly GUI is developed with app designer tool to Analize your DVB-T signals

Extracts TPS data

Extracts MPEG-2 packets and saves them as a .ts file in output. for more analysis ffmpeg would be a greate tool to seprate programs and so on...
