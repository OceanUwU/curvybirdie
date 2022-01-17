const fs = require('fs');
const { createCanvas, loadImage } = require('canvas');

(async () => {
	for (let i of fs.readdirSync('./')) {
		if (['bird.js','node_modules'].includes(i)) continue;
		let canvas = createCanvas(250, 250)
		let ctx = canvas.getContext('2d')
		for (let j of ['beakbottom', 'beaktop', 'body', 'eye', 'wing']) {
			let img = await loadImage(`${i}/${j}.png`);
			ctx.drawImage(img, 0, 0);
		}

		let out = fs.createWriteStream(`${i}/bird.png`)
		let stream = canvas.createPNGStream()
		stream.pipe(out)
		out.on('finish', () =>  console.log(`generated ${i}`))
	}
})();