const Shinsa = {
	class DBO {
		static async get( uuid ) {
			let data = null;
			await $.get( `/shinsa/json/api/v1/${uuid}` )
			.then( response => {
				console.log( `Shinsa::DBO ${response.class} ${uuid}`, response );
				if( response.status != 'ok' ) {
					console.log( response );
					return null;
				}

				data = response.payload;
			});

			const handler = {
				get( target, prop, receiver ) {
					if( prop of target ) {
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

			return new Proxy( data, handler );
		}

		static is_list( value ) {
		}

		static is_uuid( value ) {
		}
	}
};
