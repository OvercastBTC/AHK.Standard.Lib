#SingleInstance Force

#Include <Tools\Counter>
#Include <Utils\Choose>
#Include <App\Git>
#Include <Extensions\Json>
#Include <Abstractions\Text>
#Include <Tools\Info>
#Include <Utils\Win>
#Include <App\Browser>
#Include <Extensions\String>
#Include <Converters\DateTime>
#Include <Tools\CleanInputBox>


^+!c::RecLibMgr.CreateNewRec()
^+!d::RecLibMgr.DeleteRec()
^+!t::RecLibMgr.ShowRecLib()


class RecLibMgr {
	
	static RecLibJsonPath := A_ScriptDir "\RecLib.json"
	
	static RecLib := JSON.parse(ReadFile(this.RecLibJsonPath))
	
	static ShowRecLib() {
		Infos(this.RecLib['Hot Work - Create']['title']) ; Class.Map[Rec Nickname][key (i.e., title, rec, hazard, etc.)]
	}



	static ChooseRecs(input) {
		
		Rec := this.RecLib.Choose(input)

		if (Rec){
			return Rec
		}

		if (!Rec) {
			Infos('No recommendation match found.',4000)
			Infos('No recommendation match found.',4000)
			return
		}
		
		; for key, value in this.RecLib { 
		; 	Infos(key)
		; 	; Infos("Title: " value["title"])
		; 	; Infos("Recommendation: " value["recommendation"]) 
		; 	; Infos("Hazard: " value["hazard"])
		; 	; Infos("Technical Detail: " value["technical detail"])
		; 	; A_Clipboard := ""
		; 	; A_Clipboard := value["technical detail"]
		; 	; ClipWait(500)
		; 	; A_Clipboard := ""
		; 	; A_Clipboard := value["hazard"]
		; 	; ClipWait(500)
		; 	; A_Clipboard := ""
		; 	; A_Clipboard := value["recommendation"]
		; 	; ClipWait(500)
		; 	; A_Clipboard := ""
		; 	; A_Clipboard := value["title"]
		; 	; ClipWait(500)
		; }
	}

	static ApplyJson() => WriteFile(this.RecLibJsonPath, JSON.stringify(this.RecLib))


	static CreateNewRec() {
		
		myGui := Gui(,"Add New Recommendation To Library",)
		myGui.Opt("AlwaysOnTop")
		myGui.SetFont("s12")
		myGui.Add("Text",, "Recommendation Nickname `(i.e., `"Hot Work - Create Program`"`)")
		myGui.Add("Edit","vRecNick w875", ,).Focus()
		myGui.Add("Text",, "Title")
		myGui.Add("Edit","vRecTitle w875",,)
		myGui.Add("Text",, "Recommendation Text")
		myGui.Add("Edit","vRecText w875 h150",,)
		myGui.Add("Text",, "Hazard `(Optional - For Horizon Only`)")
		myGui.Add("Edit","vRecHazard w875 h150",,)
		myGui.Add("Text",, "Techincal Detail `(Optional - For Horizon Only`)")
		myGui.Add("Edit","vRecTechDetail w875 h300",,)
		myGui.Add("Button","x15 +default", "Save").OnEvent("Click", ClickedSave)
		myGui.Add("Button","x+m", "Cancel").OnEvent("Click", ClickedCancel)
		myGui.Show("w900")
	
		ClickedSave(*)
		{
			Saved := myGui.Submit()  ; Save the contents of named controls into an object.
			
			this.RecLib.Set(Saved.RecNick.ToTitle(), Map("title", Saved.RecTitle,	"recommendation", Saved.RecText, "hazard", Saved.RecHazard, "technical detail", Saved.RecTechDetail))
			
			this.ApplyJson()

			myGui.Destroy()
		}
	
		ClickedCancel(*)
		{
			myGui.Destroy()
		}	
	}


	static DeleteRec(input := '') {
		
		if (!input) {
			input := CleanInputBox().WaitForInput()
		}
		
		RecNick := this.RecNickMap.Choose(input)
				
		this.RecLib.Delete(RecNick)
		
		this.ApplyJson()

		}


	; static _ValidateSetInput(input, regex) {
	; 	input := CompressSpaces(input)

	; 	RegexMatch(input, regex, &match)
	; 	if !match {
	; 		Info("Wrong!")
	; 		return false
	; 	}
	; 	return match
	; }


	static RecLibArr {
		get {
			RecLib := []
			for key, _ in this.RecLib {
				RecLib.Push(key)
			}
			return RecLib
		}
	}

	static RecNickMap {
		get {
			RecLib := Map()
			for key, value in this.RecLib {
				RecLib.Set(key,key)
			}
			return RecLib
		}
	}


/* 	static Run(progressType?) {
		Browser.RunLink(this._GetLink(progressType?))
	}

	static DeleteShow(isDropped := false) {
		if !show := Choose(this.showsArr*)
			return
		this.shows.Delete(show)
		this.ApplyJson()
		this._OperateConsumed(show, isDropped)
	}

	static SetLink(show_and_link) {
		if !show_and_link := this._ValidateSetInput(show_and_link, "(.+) (" this._linkRegex ")") {
			return false
		}

		show := show_and_link[1].ToTitle()
		link := show_and_link[2]

		if !this.shows.Has(show) {
			this._CreateBlankShow(show)
		}
		this.shows[show]["link"] := link

		this.ApplyJson()
		Info(show ": link set")
	}

	static UpdateLink(link) {
		if !link := this._ValidateSetInput(link, this._linkRegex) {
			return false
		}

		if !show := Choose(this.showsArr*) {
			return false
		}

		this.shows[show]["link"] := link

		this.ApplyJson()
		Info(show ": link updated")
	}

	static SetEpisode(episode) {
		if !episode := this._ValidateSetInput(episode, "\d+")[] {
			return false
		}

		if !show := Choose(this.showsArr*)
			return
		this.shows[show]["episode"] := episode
		this.shows[show]["timestamp"] := DateTime.Date " " DateTime.Time

		if episode > this.shows[show]["downloaded"] {
			this.shows[show]["downloaded"] := episode
		}

		this._OperateEpisode(show, episode)
	}

	static SetDownloaded(downloaded) {
		if !downloaded := this._ValidateSetInput(downloaded, "\d+")[] {
			return false
		}

		if !show := Choose(this.showsArr*)
			return
		this.shows[show]["downloaded"] := downloaded

		this._OperateDownloaded(show, downloaded)
	}


	static _GetLink(progressType := "episode") {
		if !show := Choose(this.showsArr*)
			return
		nextEp := this.shows[show][progressType] + 1
		Counter.num := nextEp
		return this.shows[show]["link"] nextEp
	}





	static _OperateConsumed(show, isDropped) => (this._WriteConsumed(show, isDropped), this._PushConsumed(show, isDropped))

	static _WriteConsumed(show, isDropped) {
		date := "`n1. " DateTime.Date " - "
		isDropped_string := isDropped ? "(dropped) " : ""
		AppendFile(this.ConsumedPath, date isDropped_string show.ToTitle())
	}

	static _PushConsumed(show, isDropped) {
		action := isDropped ? "drop" : "finish"
		Info(action " " show)
		Git(Paths.Shows)
			.Add(this.ConsumedPath, this.RecLibJsonPath)
			.Commit(action " " show)
			.Push()
			.Execute()
		Info("pushed!")
	}

	static _OperateEpisode(show, episode) {
		this.ApplyJson()
		Info(show ": " episode)
		Git(Paths.Shows)
			.Add(this.RecLibJsonPath)
			.Commit("watch ep" episode " -> " show)
			.Push()
			.Execute()
		Info("pushed!")
	}

	static _OperateDownloaded(show, downloaded) {
		this.ApplyJson()
		Info(show ": " downloaded)
	} */
}