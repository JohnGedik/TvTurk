' ********** Copyright 2016 Roku Corp.  All Rights Reserved. ********** 
 ' inits grid screen
 ' creates all children
 ' sets all observers 
Function Init()
    ' GridScreen node with RowList
    m.gridScreen = m.top.findNode("GridScreen")

    ' Observer to handle Item selection on RowList inside GridScreen (alias="GridScreen.rowItemSelected")
    m.top.observeField("rowItemSelected", "OnRowItemSelected")
    
    ' loading indicator starts at initializatio of channel
    m.loadingIndicator = m.top.findNode("loadingIndicator")
	
	m.videoPlayer       =   m.top.findNode("VideoPlayer")

	m.Poster = m.top.findNode("poster")
	m.Label = m.top.findNode("label")
	m.Label.color = "#383838"
	
	if (m.global.DeepContentFound = "Y")
	? "Playing DeepContent"
	  videoContent = createObject("RoSGNode", "ContentNode")
	  videoContent.url = m.global.DeepContentURL
	  videoContent.title = m.global.DeepContenttitle
	  videoContent.streamformat = m.global.DeepContentStreamFormat

	   m.videoPlayer.content = videoContent
	   PlayVideo()
	end if
End Function 

Function PlayVideo()
	m.videoPlayer.control   = "prebuffer"
	m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
	m.videoPlayer.control   = "play"
	
	if m.videoPlayer.content.streamformat = "hls" then
		m.videoPlayer.enableTrickPlay = false
	else
		m.videoPlayer.enableTrickPlay = true
	end if
	? "m.global.DeepContentDescription="; m.global.DeepContentDescription
	if not m.global.DeepContentDescription = "audio/mp3"
		m.gridScreen.visible = "false"
		m.videoPlayer.visible = true
		m.videoPlayer.setFocus(true)
		m.loadingIndicator.control = "stop"
		m.label.visible = false
	else
        m.Label.text = m.global.DeepContentTitle + " Caliyor"
		m.label.visible = true
	end if
End Function

' if content set, focus on GridScreen
Function OnChangeContent()
    m.gridScreen.setFocus(true)
    m.loadingIndicator.control = "stop"
End Function

' Row item selected handler
Function OnRowItemSelected()
    ' On select any item on home scene, show Details node and hide Grid
	m.content = m.gridScreen.focusedContent
    m.videoPlayer.content   = m.content
    m.videoPlayer.content.streamformat   = m.content.streamformat
	m.videoPlayer.control   = "prebuffer"
	m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
	m.videoPlayer.control   = "play"
	
	if m.videoPlayer.content.streamformat = "hls" then
		m.videoPlayer.enableTrickPlay = false
	else
		m.videoPlayer.enableTrickPlay = true
	end if

	? m.content.description
	
	if not m.content.description = "audio/mp3"
		m.gridScreen.visible = "false"
		m.videoPlayer.visible = true
		m.videoPlayer.setFocus(true)
		m.loadingIndicator.control = "stop"
		m.label.visible = false
	else
        m.Label.text = m.content.title + " Caliyor"
		m.label.visible = true
	end if

    m.top.streamUrl         = m.content.url
	m.mediaType				= m.content.mediaType		
End Function

' Main Remote keypress event loop
Function OnKeyEvent(key, press) as Boolean
    result = false
    if press then
        if key = "options"
            ' option key handler
        else if key = "back"			
			if m.videoPlayer.visible = true
				m.videoPlayer.visible = false
				m.videoPlayer.control = "stop"
				m.gridScreen.visible = "true"
				m.gridScreen.setFocus(true)
				result = true
			end if
		end if
    end if
    return result
End Function

' event handler of Video player msg
Sub OnVideoPlayerStateChange()
    if m.videoPlayer.state = "error"
        ' error handling
        m.videoPlayer.visible = false
    else if m.videoPlayer.state = "playing"
        ' playback handling
    else if m.videoPlayer.state = "finished"
        m.videoPlayer.visible = false
    end if
End Sub
