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

// ============================================================
function createRandomBirthday() {
// ============================================================
	let now  = DateTime.now();
	let age  = Math.floor( PD.rbeta( 1, 1, 4.7 )[0] * 84 ) + 8;
	let days = Math.floor( Math.random() * 365 );
	let dob  = now.minus({ years : age }).minus({ days });
	return dob;
}

// ============================================================
function createRandomRankHistory( dob ) {
// ============================================================
	let age  = DateTime.now().year - dob.year;
	let n    = Math.ceil( Math.log( age - 6 ) / Math.log( 2 ));
	let rank = Math.round( PD.rbeta( 1, 4, 2 )[ 0 ] * n );
	if( rank == 0 ) { rank = 1; }

	let history = [];
	let date    = DateTime.now();
	for( let i = rank; i > 0; i-- ) {
		let days      = PD.rbeta( 1, 2, 8 )[0] * i * n * 365;
		let promotion = date.minus({ days });
		let age       = promotion.year - dob.year;
		let danpoom   = age <= 14 ? 'poom' : 'dan';
		if( danpoom == 'poom' && rank > 4 ) { danpoom = 'dan'; }
		history.push({ rank : i, danpoom, date : promotion.toUTC().toISO() });

		if( days < (i * 365) ) {
			days = (i + PD.rbeta( 1, 2, 8 )[ 0 ]) * 365;
			date = date.minus({ days });

		} else {
			date = promotion
		}
	}
	return history;
}

// ============================================================
function createRandomUser() {
// ============================================================
	const sex   = faker.name.sexType();
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

// ============================================================
function createRandomPromotionTest( poster ) {
// ============================================================
	const city    = faker.address.cityName();
	const country = 'USA';
	const state   = faker.address.state();
	const start   = DateTime.now().minus({ days : PD.rbeta( 1, 2, 10 )[ 0 ] * 3650 });
	const stop    = start.plus({ days : Math.floor( PD.rbeta( 1, 2, 10 )[ 0 ] * 3 ) + 1 });
	
	return {
		uuid : faker.datatype.uuid(),
		name : `${state} State Kukkiwon Dan Promotion Test`,
		poster : poster.uuid,
		host : `${state} Taekwondo Association`,
		address1 : faker.address.streetAddress(),
		city, state, country,
		daystart : start.toUTC().toISODate(),
		daystop : stop.toUTC().toISODate()
	};
}

for( let i = 0; i < 10; i++ ) {
	let poster = createRandomUser();
	let test   = createRandomPromotionTest( poster );
	console.log( poster );
	console.log( test );
}


