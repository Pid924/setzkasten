# Setzkasten

เกมต่อคำศัพท์ภาษาเยอรมันบนกระดานตัวอักษร ลากตัวอักษรที่อยู่ติดกันให้เป็นคำ พร้อมคำแปลไทยและเพศของคำนาม (der/die/das)

ตัวเกมหลักเขียนด้วย **Godot 4.3** อยู่ในโฟลเดอร์ `godot/` ทุกครั้งที่ push เข้า `main` GitHub Actions จะ export เป็นเวอร์ชันเว็บแล้ว deploy ขึ้น GitHub Pages ให้อัตโนมัติ

- เวอร์ชัน Godot: https://pid924.github.io/setzkasten/
- เวอร์ชัน HTML เดิม (ไฟล์เดียว `html/index.html`): https://pid924.github.io/setzkasten/html/

เปิดโปรเจกต์ใน Godot: เปิด Godot 4.3 แล้วเลือก Import → `godot/project.godot`

## เปิดใช้ GitHub Pages ครั้งแรก
Settings → Pages → Build and deployment → Source: **GitHub Actions**

## โหมดเกม
- **Klassisch (คลาสสิก):** ทำคะแนนให้ถึงเป้าเพื่อผ่านบท ระวังหยดหมึกที่นับถอยหลัง
- **Kampf (ต่อสู้):** คะแนนของคำกลายเป็นดาเมจ (คะแนน ÷ 10) ศัตรู 8 ตัวจากโลกโรงพิมพ์ เลือดและแรงโจมตีเพิ่มขึ้นทุกด่าน ป้ายสีเขียว +HP ฟื้นเลือด ป้าย ×2/×3 เพิ่มดาเมจ

## ภาษาและคำแปลจากผู้เล่น
- เลือกภาษาเมนู ไทย / English / Nederlands ได้ตอนเลือกโหมด ข้อความทั้งเกมและคำแปลเปลี่ยนตาม
- คำที่ยังไม่มีคำแปลในภาษาที่เลือก กด "+ เพิ่มคำแปล" ได้ บันทึกไว้ในเบราว์เซอร์ของผู้เล่น และแสดง (จากผู้เล่น) ต่อท้าย
- สลับตัวอักษรและใช้คำใบ้มีกล่องยืนยันพร้อมติ๊ก "ไม่ต้องถามอีก" คำใบ้ใช้ได้ไม่จำกัดแต่เสียเลือด 3 (โหมดคลาสสิกเสีย 50 คะแนน)

## คำแปล
กดปุ่ม ไทย / EN / NL ในสมุดคำศัพท์เพื่อเลือกภาษาคำแปล (เกมจำภาษาที่เลือกไว้) คำที่ผันรูปจะแสดงรูปพจนานุกรมด้วย เช่น HÄUSER → das Haus

## สร้างคลังคำใหม่
สคริปต์อยู่ใน `tools/` (`build_dict.py` สร้างคำแปล แล้ว `mkhtml.py` รวมเป็น `html/index.html`) ข้อมูลที่เกม Godot ใช้อยู่ใน `godot/data/` ส่วนคำแปลไทยที่เขียนเองอยู่ใน `tools/gloss.txt` และคำเชื่อม/สรรพนามอยู่ใน `tools/fx.txt`

## ที่มาของคลังคำ
- รายการคำความถี่สูงจาก [FrequencyWords](https://github.com/hermitdave/FrequencyWords) (OpenSubtitles 2018)
- กรองด้วยพจนานุกรม Hunspell de_DE ([wooorm/dictionaries](https://github.com/wooorm/dictionaries))
- คำแปลดัตช์: FreeDict deu-nld (และ nld-eng สำหรับเทียบเป็นอังกฤษ)
- เชื่อมความหมายด้วย [OdeNet](https://github.com/hdaSprachtechnologie/odenet) (CC BY-SA 4.0), Princeton WordNet 3.0, Thai WordNet และ Open Dutch WordNet ผ่าน [OMW](https://github.com/omwn/omw-data)
- เพศของคำนามและรูปผัน: [german-nouns](https://pypi.org/project/german-nouns/) (ข้อมูลจาก Wiktionary, CC BY-SA)
