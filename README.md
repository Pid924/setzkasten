# Setzkasten

เกมต่อคำศัพท์ภาษาเยอรมันบนกระดานตัวอักษร ลากตัวอักษรที่อยู่ติดกันให้เป็นคำ พร้อมคำแปลไทยและเพศของคำนาม (der/die/das)

ทั้งเกมอยู่ในไฟล์เดียว `index.html` ทุกครั้งที่ push เข้า `main` GitHub Actions จะ deploy ขึ้น GitHub Pages ให้อัตโนมัติ

## เปิดใช้ GitHub Pages ครั้งแรก
Settings → Pages → Build and deployment → Source: **GitHub Actions**

## ที่มาของคลังคำ
- รายการคำความถี่สูงจาก [FrequencyWords](https://github.com/hermitdave/FrequencyWords) (OpenSubtitles 2018)
- กรองด้วยพจนานุกรม Hunspell de_DE ([wooorm/dictionaries](https://github.com/wooorm/dictionaries))
