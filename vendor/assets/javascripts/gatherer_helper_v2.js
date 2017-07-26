var wizardsURL = 'http://gatherer.wizards.com/Handlers/Image.ashx?type=card&name=';

/**
*	Wizards
*/
function getWizardsCardName(cardName){
	return cardName.replace(/&#8217;/g,"").replace(/\/g,"").replace(/\’/g,"'").replace(/-/g," ").replace(/\s+/g," ").replace(/ /g,"%20");
}
function getWizardsHtml(cardName){
	return "<img src=\""+wizardsURL+getWizardsCardName(cardName)+".jpg\" onerror=\"this.onerror=null;this.onmouseout=null;this.onmouseover=null;this.src='mtg_card_back.jpg';\"/>";
}

function getWizardsSrc(cardName){
	return wizardsURL+getWizardsCardName(cardName);
}

function getWizardsOnError(e){
	return function(e) {
		this.onerror=null;
		this.onmouseout=null;
		this.onmouseover=null;
		this.src="https://sites.google.com/site/themunsonsapps/mtg/mtg_card_back.jpg";
	};
}
