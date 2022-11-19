const { faker } = require( '@faker-js/faker' );
const { DateTime } = require( 'luxon' );
const PD = require( 'probability-distributions' );

const settings = {
	age : {
		min : 8,
		max : 92,
		mode : 'age'
	},
	id : {
		digits : 7,
		options : { bannedDigits: [ '0' ]}
	}
};

function createRandomBirthday() {
	let now  = DateTime.now();
	let age  = Math.floor( PD.rbeta( 1, 1, 4.7 )[0] * 84 ) + 8;
	let days = Math.floor( Math.random() * 365 );
	let dob  = now.minus({ years : age }).minus({ days });
	return dob;
}

function createRandomRankHistory( dob ) {
	let age  = DateTime.now().year - dob.year;
	let n    = Math.ceil( Math.log( age - 6 ) / Math.log( 2 ));
	let rank = Math.round( PD.rbeta( 1, 4, 2 )[ 0 ] * n );
	if( rank == 0 ) { rank = 1; }
	console.log( `Age: ${age}, n: ${n}` );

	let history = [];
	let date    = DateTime.now();
	for( let i = rank; i > 0; i-- ) {
		let days = PD.rbeta( 1, 2, 8 )[0] * i * n * 365;
		console.log( `Days 1: ${days}` );
		let promotion = date.minus({ days });
		history.push({ rank : i, date : promotion.toUTC().toISO() });

		if( days < (i * 365) ) {
			days = (i + PD.rbeta( 1, 2, 8 )[ 0 ]) * 365;
			console.log( `Days 2: ${days}` );
			date = date.minus({ days });

		} else {
			date = promotion
		}
	}
	return history;
}

for( let i = 0; i < 10; i++ ) {
	let dob = createRandomBirthday();
	let history = createRandomRankHistory( dob );
	console.log( dob.toUTC().toISO());
	console.log( history );
}

function createRandomUser() {
	const sex   = this.faker.name.sexType();
	const fname = faker.name.firstName( sex );
	const lname = faker.name.lastName();
	const email = faker.helpers.unique( faker.internet.email, [ fname, lname ]);
	const id    = faker.helpers.unique( faker.random.numeric, [ settings.id.digits, settings.id.options ]);
	const dob   = createRandomBirthday();
	const noc   = faker.address.countryCode( 'alpha-3' );

	return {
		uuid : faker.datatype.uuid(),
		id : `0${id}`,
		fname, lname, email,
		pwhash : null,
		role : null,
		dob : dob.toUTC().toISO(),
		gender : sex.substr( 0, 1 ),
		rank : createRandomRankHistory( dob ),
		noc
	}
}
