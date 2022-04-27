import requests
import xml.etree.ElementTree as ET
import json

appKey = 'acc38164845454913c919d70c34b6afb'
appSecret = '792e854a83cc0a01'
groupID = '1347235@N20'

photoURLs = list()
for i in range(1, 12):
    cmd = 'http://api.flickr.com/services/rest/?'+'method=flickr.groups.pools.getPhotos' + '&api_key=' + appKey + '&group_id=' + groupID + '&per_page=500' + '&page=' + str(i)
    response = requests.get(cmd)
    test = ET.fromstring(response.text)
    p = test[0]
    i = 1

    for child in p:
        photoURLs.append('https://live.staticflickr.com/'+str(child.attrib.get('server') + '/' + str(child.attrib.get('id')+'_'+str(child.attrib.get('secret')+'_t.jpg'))))
        print(photoURLs[len(photoURLs)-1])

    
finalPhotoURLs = set()
for url in photoURLs:
    finalPhotoURLs.add(url)

print(len(finalPhotoURLs))

with open('nature.csv', 'w') as f:
    i = 1
    for url in finalPhotoURLs:
        f.write(str(i) + ', ')
        f.write(url)
        f.write(', INSERT_FILEPATH_HERE')
        f.write('\n')
        i+=1