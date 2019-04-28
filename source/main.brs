sub Main(args as Dynamic)
    ' listen on port 8085 for debugging
    print "################"
    print "Start of Channel"
    print "################"

    screen = CreateObject("roSGScreen")
    
    'Deep linking params
	'args.ContentID = "10007"		' *DEBUG
	'args.MediaType = "video/mp4"	' *DEBUG
	m.global = screen.getGlobalNode()

    m.global.addField("DeepContentFound", "string", true)
    m.global.DeepContentFound = "N"
    if (args.ContentId <> invalid) and (args.MediaType <> invalid)
        m.global.addField("DeepContentId", "string", true)
        m.global.addField("DeepMediaType", "string", true)

        m.global.DeepContentId = args.ContentId
        m.global.DeepMediaType = args.MediaType
    end if

    scene = screen.CreateScene("HomeScene")
    port = CreateObject("roMessagePort")

    mediaList = GetMediaList("https://s3.amazonaws.com/roku.playlist/mediaList_TEST.xml")
    
    screen.SetMessagePort(port)
    screen.Show()
      
    scene.gridContent = ParseXMLContent(mediaList)

    while true
        msg = wait(0, port)
        print "------------------"
        print "msg = "; msg
    end while
    
    if screen <> invalid then
        screen.Close()
        screen = invalid
    end if
End Sub


Function ParseXMLContent(list As Object)
    RowItems = createObject("RoSGNode","ContentNode")
    
    for each rowAA in list
        row = createObject("RoSGNode","ContentNode")
        row.Title = rowAA.Title

        for each itemAA in rowAA.ContentList
            item = createObject("RoSGNode","ContentNode")
            ' We don't use item.setFields(itemAA) as doesn't cast streamFormat to proper value
            for each key in itemAA
                item[key] = itemAA[key]
            end for
            row.appendChild(item)
        end for
        RowItems.appendChild(row)
    end for

    return RowItems
End Function

Function GetMediaList(urlStr as String)
    url = CreateObject("roUrlTransfer")
	url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)
	rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()

    result = []

    for each xmlItem in responseXML
        item = {}
        item["title"] = xmlItem.getAttributes().title
        item["contentlist"] = GetApiArray(xmlItem.getAttributes().feed)
        result.push(item)
    end for

    return result
End Function

Function GetApiArray(urlStr as String)
    url = CreateObject("roUrlTransfer")
	url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(urlStr)
	rsp = url.GetToString()

    responseXML = ParseXML(rsp)
    responseXML = responseXML.GetChildElements()
    responseArray = responseXML.GetChildElements()

    result = []

    for each xmlItem in responseArray
        if xmlItem.getName() = "item"
            itemAA = xmlItem.GetChildElements()
            if itemAA <> invalid
                item = {}
                for each xmlItem in itemAA
                    item[xmlItem.getName()] = xmlItem.getText()
                    if xmlItem.getName() = "media:content"
                        item.stream = {url : xmlItem.url}
                        item.url = xmlItem.getAttributes().url
                        item.streamFormat = xmlItem.getAttributes().streamformat
						item.isDefault = xmlItem.getAttributes().isDefault
						item.mediaType = xmlItem.getAttributes().mediaType
                        
                        mediaContent = xmlItem.GetChildElements()
                        for each mediaContentItem in mediaContent
                            if mediaContentItem.getName() = "media:thumbnail"
                                item.HDPosterUrl = mediaContentItem.getattributes().url
                                item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
                            end if
							if mediaContentItem.getName() = "media:contentID"
								if mediaContentItem.getText() = m.global.DeepContentId
									m.global.DeepContentFound = "Y"
									m.global.addField("DeepContentTitle", "string", true)
									m.global.DeepContentTitle = Item.title

									m.global.addField("DeepContentURL", "string", true)
									m.global.DeepContentURL = item.url

									m.global.addField("DeepContentStreamFormat", "string", true)
									m.global.DeepContentStreamFormat = item.streamFormat

									m.global.addField("DeepContentDescription", "string", true)
									m.global.DeepContentDescription = item.description
									?m.global.DeepContentURL
								end if
							end if
                        end for
                    end if
                end for
                result.push(item)
            end if
        end if
    end for

    return result
End Function

Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function
