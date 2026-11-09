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
		"tagC": "โหมดคลาสสิก", "tagB": "โหมดต่อสู้", "sndOn": "เสียง: เปิด", "sndOff": "เสียง: ปิด",
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
		"winB": "ชนะ {o} แล้ว!\nได้เลือดคืน 20\n\nด่าน {c}: {n}\nเลือด {h} · ตีครั้งละ {a} ทุก {e} ตา", "fight": "สู้ต่อ",
		"overB": "คะแนนรวม {s}\n{where} · สร้างได้ {n} คำ", "reachedC": "ถึงบทที่ {c}", "reachedB": "ถึงด่านที่ {c} ({n})",
		"bestW": "คำที่ดีที่สุด: {w} ({p})", "again": "เล่นใหม่", "close": "ปิด", "dictBtn": "คำศัพท์ที่ใช้แล้ว ({n})",
		"rules": "• เลือกตัวอักษรที่อยู่ติดกัน (รวมแนวทแยง) อย่างน้อย 3 ตัวให้เป็นคำภาษาเยอรมัน แล้วกดส่งคำ หรือลากแล้วปล่อยนิ้ว\n• คำยาวได้คะแนนคูณเพิ่ม ตัวอักษรหายาก (Ä Ö Ü J Q X Y) มีค่าสูง ป้าย CH นับเป็นสองตัวอักษร\n• ใช้ ss แทน ß เช่น STRASSE, FUSS\n• คำ 5–6 ตัวได้ป้ายแดง ×2 คำ 7 ตัวขึ้นไปได้ป้ายทอง ×3\n• คลาสสิก: หยดหมึกนับถอยหลัง ถ้าถึง 0 เสียขนนก 1 อัน\n• ต่อสู้: คะแนน ÷ 10 = ดาเมจ ศัตรูนับถอยหลังแล้วตีกลับ ป้ายเขียว +HP ฟื้นเลือด\n• สลับตัวอักษรนับเป็นหนึ่งตา คำใบ้ใช้ได้ไม่จำกัดแต่เสียเลือด 3 (คลาสสิกเสีย 50 คะแนน)\n• คำไหนยังไม่มีคำแปล กดเพิ่มคำแปลเองได้",
		"foe": ["หยดหมึกจอมซน", "เหาหนังสือ", "ปีศาจคำพิมพ์ผิด", "เสือกระดาษ", "โกเลมสนิม", "อักษรเงา", "ผู้ตรวจเซ็นเซอร์", "มังกรตะกั่ว"],
	},
	"en": {
		"changeMode": "Change mode", "score": "Score", "chapter": "Chapter", "stage": "Stage", "lives": "Quills", "best": "Best",
		"you": "You", "hp": "HP", "tap": "Tap or drag letters", "notword": "Not a word",
		"submit": "Submit", "dmg": "damage", "clear": "Clear", "hint": "Hint", "shuffle": "Shuffle", "howto": "How to play", "dict": "Wörterbuch",
		"tagC": "Classic", "tagB": "Battle", "sndOn": "Sound: on", "sndOff": "Sound: off",
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
		"winB": "You defeated {o}!\nYou recover 20 HP.\n\nStage {c}: {n}\n{h} HP · hits for {a} every {e} turns", "fight": "Fight on",
		"overB": "Total score {s}\n{where} · {n} words made", "reachedC": "Reached chapter {c}", "reachedB": "Reached stage {c} ({n})",
		"bestW": "Best word: {w} ({p})", "again": "Play again", "close": "Close", "dictBtn": "Words used ({n})",
		"rules": "• Pick at least 3 touching letters (diagonals count) that form a German word, then press Submit or drag and let go.\n• Longer words multiply your score. Rare letters (Ä Ö Ü J Q X Y) are worth more. The CH tile counts as two letters.\n• Write ss for ß, e.g. STRASSE, FUSS.\n• 5–6 letter words create a red ×2 tile, 7+ letters a gold ×3 tile.\n• Classic: ink blots count down. At 0 you lose a quill.\n• Battle: score ÷ 10 = damage. Enemies count down and hit back. Green +HP tiles heal you.\n• Shuffling counts as a turn. Hints are unlimited but cost 3 HP (50 points in Classic).\n• Missing a translation? Add your own.",
		"foe": ["mischievous ink blot", "book louse", "typo devil", "paper tiger", "rust golem", "shadow script", "censor", "lead dragon"],
	},
	"nl": {
		"changeMode": "Modus wijzigen", "score": "Score", "chapter": "Hoofdstuk", "stage": "Level", "lives": "Veren", "best": "Record",
		"you": "Jij", "hp": "HP", "tap": "Tik of sleep letters", "notword": "Geen woord",
		"submit": "Inzetten", "dmg": "schade", "clear": "Wissen", "hint": "Hint", "shuffle": "Schudden", "howto": "Spelregels", "dict": "Wörterbuch",
		"tagC": "Klassiek", "tagB": "Gevecht", "sndOn": "Geluid: aan", "sndOff": "Geluid: uit",
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
		"winB": "Je hebt {o} verslagen!\nJe herstelt 20 HP.\n\nLevel {c}: {n}\n{h} HP · slaat {a} elke {e} beurten", "fight": "Verder vechten",
		"overB": "Totale score {s}\n{where} · {n} woorden gemaakt", "reachedC": "Hoofdstuk {c} bereikt", "reachedB": "Level {c} bereikt ({n})",
		"bestW": "Beste woord: {w} ({p})", "again": "Opnieuw spelen", "close": "Sluiten", "dictBtn": "Gebruikte woorden ({n})",
		"rules": "• Kies minstens 3 aangrenzende letters (ook diagonaal) die een Duits woord vormen en druk op Inzetten, of sleep en laat los.\n• Langere woorden vermenigvuldigen je score. Zeldzame letters (Ä Ö Ü J Q X Y) zijn meer waard. De CH-tegel telt als twee letters.\n• Schrijf ss voor ß, bijv. STRASSE, FUSS.\n• Woorden van 5–6 letters maken een rode ×2-tegel, 7+ letters een gouden ×3-tegel.\n• Klassiek: inktvlekken tellen af. Bij 0 verlies je een veer.\n• Gevecht: score ÷ 10 = schade. Vijanden tellen af en slaan terug. Groene +HP-tegels genezen je.\n• Schudden telt als een beurt. Hints zijn onbeperkt maar kosten 3 HP (50 punten in Klassiek).\n• Ontbreekt een vertaling? Voeg je eigen toe.",
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
