# Setzkasten

เกมต่อคำศัพท์ภาษาเยอรมันบนกระดานตัวอักษร ลากตัวอักษรที่อยู่ติดกันให้เป็นคำ พร้อมคำแปลไทยและเพศของคำนาม (der/die/das)

ทั้งเกมอยู่ในไฟล์เดียว `index.html` ทุกครั้งที่ push เข้า `main` GitHub Actions จะ deploy ขึ้น GitHub Pages ให้อัตโนมัติ

## เปิดใช้ GitHub Pages ครั้งแรก
Settings → Pages → Build and deployment → Source: **GitHub Actions**

## โหมดเกม
- **Klassisch (คลาสสิก):** ทำคะแนนให้ถึงเป้าเพื่อผ่านบท ระวังหยดหมึกที่นับถอยหลัง
- **Kampf (ต่อสู้):** คะแนนของคำกลายเป็นดาเมจ (คะแนน ÷ 10) ศัตรู 8 ตัวจากโลกโรงพิมพ์ เลือดและแรงโจมตีเพิ่มขึ้นทุกด่าน ป้ายสีเขียว +HP ฟื้นเลือด ป้าย ×2/×3 เพิ่มดาเมจ

## คำแปล
กดปุ่ม ไทย / EN / NL ในสมุดคำศัพท์เพื่อเลือกภาษาคำแปล (เกมจำภาษาที่เลือกไว้) คำที่ผันรูปจะแสดงรูปพจนานุกรมด้วย เช่น HÄUSER → das Haus

## สร้างคลังคำใหม่
สคริปต์อยู่ใน `tools/` (`build_dict.py` สร้างคำแปล แล้ว `mkhtml.py` รวมเป็น `index.html`) ส่วนคำแปลไทยที่เขียนเองอยู่ใน `tools/gloss.txt` และคำเชื่อม/สรรพนามอยู่ใน `tools/fx.txt`

## ที่มาของคลังคำ
- รายการคำความถี่สูงจาก [FrequencyWords](https://github.com/hermitdave/FrequencyWords) (OpenSubtitles 2018)
- กรองด้วยพจนานุกรม Hunspell de_DE ([wooorm/dictionaries](https://github.com/wooorm/dictionaries))
- คำแปลดัตช์: FreeDict deu-nld (และ nld-eng สำหรับเทียบเป็นอังกฤษ)
- เชื่อมความหมายด้วย [OdeNet](https://github.com/hdaSprachtechnologie/odenet) (CC BY-SA 4.0), Princeton WordNet 3.0, Thai WordNet และ Open Dutch WordNet ผ่าน [OMW](https://github.com/omwn/omw-data)
- เพศของคำนามและรูปผัน: [german-nouns](https://pypi.org/project/german-nouns/) (ข้อมูลจาก Wiktionary, CC BY-SA)
