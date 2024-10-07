# JWT Grant generator for [Maskinporten](https://docs.digdir.no/docs/Maskinporten/maskinporten_overordnet)

Inspired by: https://github.com/felleslosninger/jwt-grant-generator

## Usage
1. Place [virksomhetssertifikat](https://info.altinn.no/hjelp/innlogging/utgaende-innloggingsmetoder/virksomhetssertifikat/) in project directory
2. `$ cp config.example.cfg config.cfg`, then add all auth details 
3. `$ chmod +x create-grant.sh`
4. `$ ./create-grant.sh`
