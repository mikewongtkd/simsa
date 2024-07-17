const Simsa = {
	class DBO {
		static async get( uuid ) {
			let data    = null;
			let doctype = null;
			await $.get( `/shinsa/json/api/v1/${uuid}` )
			.then( response => {
				console.log( `Simsa::DBO ${response.class} ${uuid}`, response );
				if( response.status != 'ok' ) {
					console.log( response );
					return null;
				}

				data    = response.payload;
				doctype = response.class;
			});

			const handler = {
				get( target, Props, receiver ) {
					let prop   = Inflected.singularize( Props ).toLowerCase();
					let plural = Props != prop;
					if( Reflect.has( target, prop )) {
						let value = Reflect.get( ...arguments );

						if( Simsa.DBO.is_uuid( value )) {
							return Simsa.DBO.get( value );

						} else if( Array.isArray( value )) {
							return value.map( x => Simsa.DBO.is_uuid( x ) ? Simsa.DBO.get( x ) : x );

						} else {
							return value;
						}
					}

					return null;
				}

				set( target, prop, value ) {
					if( prop of target ) {
						return Reflect.set( ...arguments );
					}
				}
			};

			// Factory instantiate based on the class type
			let obj = Simsa.DBO.factory( doctype, data );

			// Wrap object in a Proxy for dynamic dispatch
			return new Proxy( obj, handler );
		}

		static factory( doctype, data ) {
			switch( doctype) {
				case 'Exam':       return new Simsa.Exam( data );
				case 'Examiner':   return new Simsa.Examiner( data );
				case 'Examinee':   return new Simsa.Examinee( data );
				case 'User':       return new Simsa.User( data );
			}
		}

		static is_uuid( value ) {
			const uuid_re = new RegExp( '^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$', 'i' ); // RFC4122
			if( typeof value !== 'string' ) { return false; }
			if( uuid_re.match( value )) { return true; }
			return false;
		}
	};
};

const Simsa.User = class User extends Simsa.DBO {
}
