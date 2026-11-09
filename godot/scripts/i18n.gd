class_name I18n
extends RefCounted
## All interface text in Thai, English and Dutch. {name} placeholders are filled by tr_fmt().

const LANGS := ["th", "en", "nl"]
const LANG_NAMES := {"th": "ไทย", "en": "English", "nl": "Nederlands"}
const GLOSS_INDEX := {"th": 1, "en": 2, "nl": 3}

const T := {
	"th": {
		"changeMode": "เปลี่ยนโหมด", "score": "คะแนน", "chapter": "บท", "stage": "ด่าน", "lives": "ขนนก", "best": "สถิติ",
		"you": "คุณ", "hp": "เลือด", "tap": "แตะหรือลากตัวอักษร", "notword": "ไม่พบคำนี้",
		"submit": "ส่งคำ", "dmg": "ดาเมจ", "clear": "ล้าง", "hint": "ใบ้", "shuffle": "สลับ", "howto": "วิธีเล่น", "dict": "Wörterbuch",
		"tagC": "โหมดคลาสสิก", "tagB": "โหมดต่อสู้", "sndOn": "เสียง: เปิด", "sndOff": "เสียง: ปิด", "itN0": "ยาฟื้นเลือด", "itN1": "โล่", "itN2": "เทตัวพิมพ์ใหม่", "itN3": "เก็บตัวตาย", "itN4": "ป้ายสี", "itN5": "+15 ดาเมจ", "itN6": "ดาเมจ ×2", "itN7": "+3 ต่อตัวอักษร", "itN8": "ตีซ้ำ", "itN9": "ดูดเลือด", "itD0": "ได้เลือด +20 ทันที", "itD1": "การโจมตีครั้งถัดไปของศัตรูเบาลง 10", "itD2": "สุ่มตัวอักษรใหม่ทุกตัวที่ไม่มีสีแดง เขียว หรือเหลือง ฟรีไม่เสียเทิร์น", "itD3": "เปลี่ยนตัวอักษรที่ใช้สร้างคำไม่ได้ 6 ตัว ฟรีไม่เสียเทิร์น", "itD4": "สุ่มเปลี่ยนตัวอักษรธรรมดา 1 ตัวให้เป็นป้ายสี (แดง ×2, เหลือง ×3 หรือเขียว +HP)", "itD5": "คำที่ส่งต่อไปตีแรงขึ้น 15", "itD6": "คำที่ส่งต่อไปตีแรงขึ้นสองเท่า (คูณหลังรวมทุกอย่างแล้ว)", "itD7": "คำที่ส่งต่อไปตีแรงขึ้นตัวอักษรละ 3", "itD8": "ส่งคำต่อไปแล้วศัตรูไม่ได้ตา ตัวนับเทิร์นศัตรูไม่เปลี่ยน", "itD9": "ได้เลือดคืน 50% ของดาเมจสุดท้ายของคำต่อไป", "itOnce": "ไอเท็มนี้ใช้ไปแล้วในเทิร์นนี้ ส่งคำก่อนแล้วค่อยใช้อีก", "itNoDead": "ทุกตัวอักษรสร้างคำได้อยู่แล้ว ไอเท็มยังไม่ถูกใช้", "itOff": "ยกเลิกแล้ว", "itGroupA": "ใช้ได้ทันที", "itGroupB": "ใช้ตอนตี (แตะเพื่อเตรียม แล้วส่งคำ)", "itHelpT": "ไอเท็ม", "itHelpB": "ได้ไอเท็มสุ่มจากทุกตัว Ä Ö Ü ในคำที่ส่ง เก็บซ้ำได้ แต่ไอเท็มเดิมใช้ได้ครั้งเดียวต่อเทิร์น", "itemGot": "ได้ไอเท็มจากสระ Umlaut: {i}", "itemExtra": "ตีซ้ำ! ศัตรูยังไม่ได้ตา ส่งคำต่อได้เลย", "endless": "เล่นต่อไม่สิ้นสุด", "finalB": "ชนะ {o} และศัตรูครบทั้ง 8 ตัวแล้ว!\n\nคะแนน {s} · ใช้คำไป {n} คำ\nเลือดสูงสุด {m}", "lockedT": "ล็อกอยู่", "lockedC": "เล่นโหมด Kampf ก่อน แล้วกลับมาที่หน้านี้ เพื่อปลดล็อกโหมดคลาสสิก", "unlockedC": "ปลดล็อกโหมดคลาสสิกแล้ว!", "hintAuto": "ใบ้เพิ่ม: เลือกตัว {l} ให้แล้ว (เหลืออีก {n} ตัว)",
		"dictEmpty": "คำที่คุณสร้างจะแสดงที่นี่ พร้อมเพศของคำนาม (der/die/das) และคำแปล",
		"chapInfo": "บทที่ {c}: {s} / {t} คะแนน เพื่อไปบทต่อไป", "stageInfo": "ด่าน {c}: สู้กับ {n}",
		"atkNext": "โจมตีตาหน้า! ({a})", "atkIn": "โจมตีในอีก {n} ตา ({a})",
		"noTr": "ยังไม่มีคำแปลภาษาไทย", "addTr": "+ เพิ่มคำแปลภาษาไทย", "fromPlayer": "จากผู้เล่น",
		"edit": "แก้ไข", "save": "บันทึก", "cancel": "ยกเลิก", "trPh": "พิมพ์คำแปลของ {w}", "wiki": "เปิด Wiktionary",
		"inkLost": "หยดหมึกซึมลงกระดาษ เสียขนนก {n} อัน", "foeHits": "{n} โจมตี! เสียเลือด {a}",
		"hintToast": "ลองหาคำที่ขึ้นต้นด้วย {l} ตรงป้ายที่กระดิก ({n} ป้าย)", "noWords": "ไม่มีคำบนกระดาน กำลังสลับให้ใหม่",
		"hintLow": "เลือดเหลือน้อยเกินไป ใช้คำใบ้ไม่ได้", "hintPts": "คะแนนไม่พอสำหรับคำใบ้",
		"cfShuffleT": "สลับตัวอักษร?", "cfShuffleB": "การสลับตัวอักษรจะข้ามเทิร์นของคุณ ถ้าถึงตาศัตรู ศัตรูจะโจมตีคุณ",
		"cfShuffleWarn": "ศัตรูจะโจมตีในเทิร์นนี้ ({a})", "cfShuffleC": "การสลับตัวอักษรนับเป็นหนึ่งตา หยดหมึกทุกหยดจะนับถอยหลังลง 1",
		"cfHintT": "ใช้คำใบ้?", "cfHintB": "คำใบ้ใช้ได้ไม่จำกัด แต่ทุกครั้งจะเสียเลือด {n}", "cfHintC": "คำใบ้ใช้ได้ไม่จำกัด แต่ทุกครั้งจะเสีย {n} คะแนน",
		"dontAsk": "ไม่ต้องถามอีก", "confirm": "ยืนยัน",
		"pickB": "เลือกภาษาและแบบเกม", "modeC": "ทำคะแนนให้ถึงเป้าเพื่อผ่านบท ระวังหยดหมึก",
		"modeB": "คะแนนกลายเป็นดาเมจ ล้มศัตรูทีละด่าน ป้าย +HP ฟื้นเลือด ป้าย ×2 เพิ่มดาเมจ", "back": "กลับไปเล่นต่อ",
		"chapB": "ผ่านบทที่ {p} แล้ว!\nได้ขนนกคืน 1 อัน\nบทนี้หยดหมึกจะมาบ่อยขึ้นและนับถอยหลังเร็วขึ้น", "go": "ไปต่อ",
		"winB": "ชนะ {o} แล้ว!\nได้เลือดคืน 20 · เลือดสูงสุดเพิ่มเป็น {m}\n\nด่าน {c}: {n}\nเลือด {h} · ตีครั้งละ {a} ทุก {e} ตา", "fight": "สู้ต่อ",
		"overB": "คะแนนรวม {s}\n{where} · สร้างได้ {n} คำ", "reachedC": "ถึงบทที่ {c}", "reachedB": "ถึงด่านที่ {c} ({n})",
		"bestW": "คำที่ดีที่สุด: {w} ({p})", "again": "เล่นใหม่", "close": "ปิด", "dictBtn": "คำศัพท์ที่ใช้แล้ว ({n})",
		"rules": "• เลือกตัวอักษรที่อยู่ติดกัน (รวมแนวทแยง) อย่างน้อย 3 ตัวให้เป็นคำภาษาเยอรมัน แล้วกดส่งคำ หรือลากแล้วปล่อยนิ้ว\n• คำยาวได้คะแนนคูณเพิ่ม ตัวอักษรหายาก (Ä Ö Ü J Q X Y) มีค่าสูง ป้าย CH นับเป็นสองตัวอักษร\n• ใช้ ss แทน ß เช่น STRASSE, FUSS\n• คำ 5–6 ตัวได้ป้ายแดง ×2 คำ 7 ตัวขึ้นไปได้ป้ายทอง ×3\n• คลาสสิก: หยดหมึกนับถอยหลัง ถ้าถึง 0 เสียขนนก 1 อัน\n• ต่อสู้: คะแนน ÷ 10 = ดาเมจ ศัตรูนับถอยหลังแล้วตีกลับ ป้ายเขียว +HP ฟื้นเลือด ชนะศัตรูแล้วเลือดสูงสุด +20 มีศัตรู 8 ด่าน\n• ใช้ Ä Ö Ü ในคำ ได้ไอเท็มสุ่มตัวละ 1 ชิ้น ไอเท็มสีเขียวใช้ได้ทันที ไอเท็มสีแดงแตะเพื่อเตรียมแล้วทำงานตอนส่งคำ ไอเท็มเดิมใช้ได้ครั้งเดียวต่อเทิร์น กด ? เพื่อดูคำอธิบาย\n• สลับตัวอักษรนับเป็นหนึ่งตา คำใบ้ใช้ได้ไม่จำกัดแต่เสียเลือด 3 (คลาสสิกเสีย 50 คะแนน)\n• คำไหนยังไม่มีคำแปล กดเพิ่มคำแปลเองได้",
		"foe": ["หยดหมึกจอมซน", "เหาหนังสือ", "ปีศาจคำพิมพ์ผิด", "เสือกระดาษ", "โกเลมสนิม", "อักษรเงา", "ผู้ตรวจเซ็นเซอร์", "มังกรตะกั่ว"],
	},
	"en": {
		"changeMode": "Change mode", "score": "Score", "chapter": "Chapter", "stage": "Stage", "lives": "Quills", "best": "Best",
		"you": "You", "hp": "HP", "tap": "Tap or drag letters", "notword": "Not a word",
		"submit": "Submit", "dmg": "damage", "clear": "Clear", "hint": "Hint", "shuffle": "Shuffle", "howto": "How to play", "dict": "Wörterbuch",
		"tagC": "Classic", "tagB": "Battle", "sndOn": "Sound: on", "sndOff": "Sound: off", "itN0": "Tonic", "itN1": "Shield", "itN2": "Fresh sorts", "itN3": "Clear dead letters", "itN4": "Colour a tile", "itN5": "+15 damage", "itN6": "Damage ×2", "itN7": "+3 per letter", "itN8": "Attack again", "itN9": "Drain", "itD0": "Heal 20 HP right away", "itD1": "The enemy's next attack hits 10 less", "itD2": "Re-roll every letter that is not red, green or yellow, free, no turn used", "itD3": "Replace 6 letters that cannot be part of any word, free, no turn used", "itD4": "Turn one plain letter into a coloured tile (red ×2, yellow ×3 or green +HP)", "itD5": "Your next word hits 15 harder", "itD6": "Your next word hits twice as hard (after all other bonuses)", "itD7": "Your next word gets +3 damage per letter", "itD8": "After your next word the enemy doesn't get a turn; its counter stays the same", "itD9": "Heal 50% of the final damage of your next word", "itOnce": "Already used this item this turn. Send a word first.", "itNoDead": "Every letter can already make a word. Item not used.", "itOff": "cancelled", "itGroupA": "Use right away", "itGroupB": "Attack items (tap to arm, then send a word)", "itHelpT": "Items", "itHelpB": "Every Ä Ö Ü in a word you send gives a random item. You can stack items, but each one can be used once per turn.", "itemGot": "Umlaut bonus! Item: {i}", "itemExtra": "Attack again! The enemy's turn has not come yet.", "endless": "Keep playing (endless)", "finalB": "You defeated {o} and all 8 enemies!\n\nScore {s} · {n} words\nMax HP {m}", "lockedT": "locked", "lockedC": "Play a Kampf round first, then come back here to unlock Classic mode", "unlockedC": "Classic mode unlocked!", "hintAuto": "Extra hint: {l} picked for you ({n} letters left)",
		"dictEmpty": "Words you make appear here with noun gender (der/die/das) and a translation",
		"chapInfo": "Chapter {c}: {s} / {t} points to the next chapter", "stageInfo": "Stage {c}: fighting {n}",
		"atkNext": "Attacks next turn! ({a})", "atkIn": "Attacks in {n} turns ({a})",
		"noTr": "No English translation yet", "addTr": "+ Add an English translation", "fromPlayer": "from a player",
		"edit": "Edit", "save": "Save", "cancel": "Cancel", "trPh": "Type the meaning of {w}", "wiki": "Open Wiktionary",
		"inkLost": "Ink soaked through: you lost {n} quill(s)", "foeHits": "{n} attacks! You lose {a} HP",
		"hintToast": "Look for a word starting with {l} on the wiggling tiles ({n} tiles)", "noWords": "No words on the board, shuffling",
		"hintLow": "Not enough HP for a hint", "hintPts": "Not enough points for a hint",
		"cfShuffleT": "Shuffle the letters?", "cfShuffleB": "Shuffling skips your turn. If the enemy's countdown runs out, it attacks you.",
		"cfShuffleWarn": "The enemy will attack this turn ({a})", "cfShuffleC": "Shuffling counts as a turn. Every ink blot counts down by 1.",
		"cfHintT": "Use a hint?", "cfHintB": "Hints are unlimited, but each one costs {n} HP.", "cfHintC": "Hints are unlimited, but each one costs {n} points.",
		"dontAsk": "Don't ask me again", "confirm": "Confirm",
		"pickB": "Choose your language and game mode", "modeC": "Reach the target score to finish each chapter. Watch out for ink blots.",
		"modeB": "Your score becomes damage. Defeat one enemy per stage. +HP tiles heal, ×2 tiles hit harder.", "back": "Back to the game",
		"chapB": "Chapter {p} complete!\nYou got a quill back.\nInk blots now come more often and count down faster.", "go": "Continue",
		"winB": "You defeated {o}!\nYou recover 20 HP and your max HP rises to {m}.\n\nStage {c}: {n}\n{h} HP · hits for {a} every {e} turns", "fight": "Fight on",
		"overB": "Total score {s}\n{where} · {n} words made", "reachedC": "Reached chapter {c}", "reachedB": "Reached stage {c} ({n})",
		"bestW": "Best word: {w} ({p})", "again": "Play again", "close": "Close", "dictBtn": "Words used ({n})",
		"rules": "• Pick at least 3 touching letters (diagonals count) that form a German word, then press Submit or drag and let go.\n• Longer words multiply your score. Rare letters (Ä Ö Ü J Q X Y) are worth more. The CH tile counts as two letters.\n• Write ss for ß, e.g. STRASSE, FUSS.\n• 5–6 letter words create a red ×2 tile, 7+ letters a gold ×3 tile.\n• Classic: ink blots count down. At 0 you lose a quill.\n• Battle: score ÷ 10 = damage. Enemies count down and hit back. Green +HP tiles heal you. Each win adds 20 max HP. There are 8 stages.\n• Every Ä Ö Ü in a word gives a random item. Green items work right away; red attack items are armed with a tap and fire with your next word. Each item once per turn. Tap ? for details.\n• Shuffling counts as a turn. Hints are unlimited but cost 3 HP (50 points in Classic).\n• Missing a translation? Add your own.",
		"foe": ["mischievous ink blot", "book louse", "typo devil", "paper tiger", "rust golem", "shadow script", "censor", "lead dragon"],
	},
	"nl": {
		"changeMode": "Modus wijzigen", "score": "Score", "chapter": "Hoofdstuk", "stage": "Level", "lives": "Veren", "best": "Record",
		"you": "Jij", "hp": "HP", "tap": "Tik of sleep letters", "notword": "Geen woord",
		"submit": "Inzetten", "dmg": "schade", "clear": "Wissen", "hint": "Hint", "shuffle": "Schudden", "howto": "Spelregels", "dict": "Wörterbuch",
		"tagC": "Klassiek", "tagB": "Gevecht", "sndOn": "Geluid: aan", "sndOff": "Geluid: uit", "itN0": "Tonicum", "itN1": "Schild", "itN2": "Nieuwe letters", "itN3": "Dode letters weg", "itN4": "Kleur een tegel", "itN5": "+15 schade", "itN6": "Schade ×2", "itN7": "+3 per letter", "itN8": "Nogmaals", "itN9": "Aftappen", "itD0": "Genees direct 20 HP", "itD1": "De volgende aanval van de vijand doet 10 minder", "itD2": "Alle letters die niet rood, groen of geel zijn opnieuw, gratis en zonder beurt", "itD3": "Vervang 6 letters die in geen enkel woord passen, gratis en zonder beurt", "itD4": "Maak van één gewone letter een gekleurde tegel (rood ×2, geel ×3 of groen +HP)", "itD5": "Je volgende woord slaat 15 harder", "itD6": "Je volgende woord slaat dubbel zo hard (na alle andere bonussen)", "itD7": "Je volgende woord krijgt +3 schade per letter", "itD8": "Na je volgende woord is de vijand niet aan de beurt; de teller blijft gelijk", "itD9": "Genees 50% van de eindschade van je volgende woord", "itOnce": "Dit item is deze beurt al gebruikt. Stuur eerst een woord.", "itNoDead": "Elke letter kan al een woord maken. Item niet gebruikt.", "itOff": "geannuleerd", "itGroupA": "Direct te gebruiken", "itGroupB": "Aanvalsitems (tik om klaar te zetten, stuur dan een woord)", "itHelpT": "Items", "itHelpB": "Elke Ä Ö Ü in een gestuurd woord geeft een willekeurig item. Items stapelen, maar elk item mag één keer per beurt.", "itemGot": "Umlaut-bonus! Item: {i}", "itemExtra": "Nog een aanval! De vijand is nog niet aan de beurt.", "endless": "Verder spelen (eindeloos)", "finalB": "Je hebt {o} en alle 8 vijanden verslagen!\n\nScore {s} · {n} woorden\nMax HP {m}", "lockedT": "op slot", "lockedC": "Speel eerst een Kampf-ronde en kom hier terug om Klassiek te ontgrendelen", "unlockedC": "Klassiek ontgrendeld!", "hintAuto": "Extra hint: {l} voor je gekozen (nog {n} letters)",
		"dictEmpty": "Je woorden verschijnen hier met lidwoord (der/die/das) en vertaling",
		"chapInfo": "Hoofdstuk {c}: {s} / {t} punten tot het volgende hoofdstuk", "stageInfo": "Level {c}: gevecht met {n}",
		"atkNext": "Valt volgende beurt aan! ({a})", "atkIn": "Valt aan over {n} beurten ({a})",
		"noTr": "Nog geen Nederlandse vertaling", "addTr": "+ Nederlandse vertaling toevoegen", "fromPlayer": "van een speler",
		"edit": "Bewerken", "save": "Opslaan", "cancel": "Annuleren", "trPh": "Typ de betekenis van {w}", "wiki": "Wiktionary openen",
		"inkLost": "De inkt is doorgelopen: {n} veer/veren kwijt", "foeHits": "{n} valt aan! Je verliest {a} HP",
		"hintToast": "Zoek een woord dat begint met {l} op de wiebelende tegels ({n} tegels)", "noWords": "Geen woorden op het bord, er wordt geschud",
		"hintLow": "Te weinig HP voor een hint", "hintPts": "Te weinig punten voor een hint",
		"cfShuffleT": "Letters schudden?", "cfShuffleB": "Schudden slaat je beurt over. Is het aftellen van de vijand op, dan valt hij je aan.",
		"cfShuffleWarn": "De vijand valt deze beurt aan ({a})", "cfShuffleC": "Schudden telt als een beurt. Elke inktvlek telt 1 af.",
		"cfHintT": "Hint gebruiken?", "cfHintB": "Hints zijn onbeperkt, maar elke hint kost {n} HP.", "cfHintC": "Hints zijn onbeperkt, maar elke hint kost {n} punten.",
		"dontAsk": "Niet meer vragen", "confirm": "Bevestigen",
		"pickB": "Kies je taal en spelmodus", "modeC": "Haal de doelscore om elk hoofdstuk te halen. Pas op voor inktvlekken.",
		"modeB": "Je score wordt schade. Versla per level één vijand. +HP-tegels genezen, ×2-tegels slaan harder.", "back": "Terug naar het spel",
		"chapB": "Hoofdstuk {p} gehaald!\nJe krijgt een veer terug.\nInktvlekken komen nu vaker en tellen sneller af.", "go": "Verder",
		"winB": "Je hebt {o} verslagen!\nJe herstelt 20 HP en je max HP stijgt naar {m}.\n\nLevel {c}: {n}\n{h} HP · slaat {a} elke {e} beurten", "fight": "Verder vechten",
		"overB": "Totale score {s}\n{where} · {n} woorden gemaakt", "reachedC": "Hoofdstuk {c} bereikt", "reachedB": "Level {c} bereikt ({n})",
		"bestW": "Beste woord: {w} ({p})", "again": "Opnieuw spelen", "close": "Sluiten", "dictBtn": "Gebruikte woorden ({n})",
		"rules": "• Kies minstens 3 aangrenzende letters (ook diagonaal) die een Duits woord vormen en druk op Inzetten, of sleep en laat los.\n• Langere woorden vermenigvuldigen je score. Zeldzame letters (Ä Ö Ü J Q X Y) zijn meer waard. De CH-tegel telt als twee letters.\n• Schrijf ss voor ß, bijv. STRASSE, FUSS.\n• Woorden van 5–6 letters maken een rode ×2-tegel, 7+ letters een gouden ×3-tegel.\n• Klassiek: inktvlekken tellen af. Bij 0 verlies je een veer.\n• Gevecht: score ÷ 10 = schade. Vijanden tellen af en slaan terug. Groene +HP-tegels genezen je. Elke overwinning geeft +20 max HP. Er zijn 8 levels.\n• Elke Ä Ö Ü in een woord geeft een willekeurig item. Groene items werken direct; rode aanvalsitems zet je klaar met een tik en werken bij je volgende woord. Elk item één keer per beurt. Tik op ? voor uitleg.\n• Schudden telt als een beurt. Hints zijn onbeperkt maar kosten 3 HP (50 punten in Klassiek).\n• Ontbreekt een vertaling? Voeg je eigen toe.",
		"foe": ["ondeugende inktvlek", "boekenluis", "zetduivel", "papieren tijger", "roestgolem", "schaduwschrift", "censor", "loden draak"],
	},
}


static func get_text(lang: String, key: String, vars: Dictionary = {}) -> Variant:
	var table: Dictionary = T.get(lang, T["th"])
	var s: Variant = table.get(key, T["th"].get(key, key))
	if s is String and not vars.is_empty():
		for k in vars:
			s = s.replace("{" + str(k) + "}", str(vars[k]))
	return s
