const Shinsa = {
	class DBO {
		static async get( uuid ) {
			let data    = null;
			let doctype = null;
			await $.get( `/shinsa/json/api/v1/${uuid}` )
			.then( response => {
				console.log( `Shinsa::DBO ${response.class} ${uuid}`, response );
				if( response.status != 'ok' ) {
					console.log( response );
					return null;
				}

				data    = response.payload;
				doctype = response.class;
			});

			const handler = {
				get( target, prop, receiver ) {
					if( Reflect.has( target, prop )) {
						let value = Reflect.get( ...arguments );

						if( Shinsa.DBO.is_uuid( value )) {
							return Shinsa.DBO.get( value );

						} else if( Shinsa.DBO.is_list( value )) {
							return value.map( x => Shinsa.DBO.is_uuid( x ) ? Shinsa.DBO.get( x ) : x );

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
			let obj = Shinsa.DBO.factory( doctype, data );

			// Wrap object in a Proxy for dynamic dispatch
			return new Proxy( obj, handler );
		}

		static factory( doctype, data ) {
			switch( doctype) {
				case 'Exam':       return new Shinsa.Exam( data );
				case 'Examiner':   return new Shinsa.Examiner( data );
				case 'Examinee':   return new Shinsa.Examinee( data );
				case 'User':       return new Shinsa.User( data );
			}
		}

		static is_list( value ) {
		}

		static is_uuid( value ) {
		}
	};
};

const Shinsa.User = class User extends Shinsa.DBO {
}
