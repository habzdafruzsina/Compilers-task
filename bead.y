%baseclass-preinclude "semantics.h"
%lsp-needed

%union
{
	std::string *szoveg;
	Tipus *tipus;
}

%token SZAMKONSTANS
%token PROGRAM
%token VALTOZOK
%token UTASITASOK
%token PROGRAM_VEGE
%token HA
%token AKKOR
%token KULONBEN
%token HA_VEGE
%token CIKLUS
%token AMIG
%token CIKLUS_VEGE
%token BE
%token KI
%token EGESZ
%token LOGIKAI
%token ERTEKADAS
%token BALZAROJEL
%token JOBBZAROJEL
%token IGAZ
%token HAMIS
%token SKIP
%token<szoveg> AZONOSITO

%left VAGY
%left ES
%left NEM
%left EGYENLO
%left KISEBB NAGYOBB KISEBBEGYENLO NAGYOBBEGYENLO
%left PLUSZ MINUSZ
%left SZORZAS OSZTAS MARADEK

%type<tipus> kifejezes

%%

start:
    kezdes deklaraciok utasitasok befejezes
    {
        std::cout << "start -> kezdes deklaraciok utasitasok befejezes" << std::endl;
    }
;

kezdes:
    PROGRAM AZONOSITO
    {
        std::cout << "kezdes -> PROGRAM AZONOSITO" << std::endl;
    }
;

befejezes:
    PROGRAM_VEGE
    {
        std::cout << "befejezes -> PROGRAM_VEGE" << std::endl;
    }
;

deklaraciok:
    // ures
    {
        std::cout << "deklaraciok -> epszilon" << std::endl;
    }
|
    VALTOZOK valtozolista
    {
        std::cout << "deklaraciok -> VALTOZOK valtozolista" << std::endl;
    }
;

valtozolista:
    deklaracio
    {
        std::cout << "valtozolista -> deklaracio" << std::endl;
    }
|
    deklaracio valtozolista
    {
        std::cout << "valtozolista -> deklaracio valtozolista" << std::endl;
    }
;

deklaracio:
    EGESZ AZONOSITO
    {
        std::cout << "deklaracio -> EGESZ AZONOSITO" << std::endl;
		if(szimbolumtabla.count(*$2) > 0)
		{
			std::cout << "Ujradefinialt valtozo: " << *$2 << std::endl
			   << "Korabbi deklaracio sora: " << szimbolumtabla[*$2].sor;
			exit(1);
		}
		szimbolumtabla[*$2] = kifejezes_leiro(d_loc__.first_line, Egesz);
		delete $2;
    }
|
    LOGIKAI AZONOSITO
    {
        std::cout << "deklaracio -> LOGIKAI AZONOSITO" << std::endl;
		if(szimbolumtabla.count(*$2) > 0)
		{
			std::cout << "Ujradefinialt valtozo: " << *$2 << std::endl
			   << "Korabbi deklaracio sora: " << szimbolumtabla[*$2].sor;
			exit(1);
		}
		szimbolumtabla[*$2] = kifejezes_leiro(d_loc__.first_line, Logikai);
		delete $2;
    }
;

utasitasok:
    UTASITASOK utasitas utasitaslista
    {
        std::cout << "utasitasok -> UTASITASOK utasitaslista" << std::endl;
    }
;

utasitaslista:
    // epsilon
    {
        std::cout << "utasitaslista -> utasitas" << std::endl;
    }
|
    utasitas utasitaslista
    {
        std::cout << "utasitaslista -> utasitas utasitaslista" << std::endl;
    }
;

utasitas:
    SKIP
    {
        std::cout << "utasitas -> SKIP" << std::endl;
    }
|
    ertekadas
    {
        std::cout << "utasitas -> ertekadas" << std::endl;
    }
|
    be
    {
        std::cout << "utasitas -> be" << std::endl;
    }
|
    ki
    {
        std::cout << "utasitas -> ki" << std::endl;
    }
|
    elagazas
    {
        std::cout << "utasitas -> elagazas" << std::endl;
    }
|
    ciklus
    {
        std::cout << "utasitas -> ciklus" << std::endl;
    }
;

ertekadas:
    AZONOSITO ERTEKADAS kifejezes
    {
        std::cout << "ertekadas -> AZONOSITO ERTEKADAS kifejezes" << std::endl;
		if(szimbolumtabla.count(*$1) == 0)
		{
			error((std::string("Nem definialt valtozo: ") + *$1).c_str());
			exit(1);
		}
		if(szimbolumtabla[*$1].ktip != *$3)
		{
			error("Tipushibas ertekadas");
			exit(1);
		}
		delete $1;
		delete $3;
    }
;

be:
    BE AZONOSITO
    {
        std::cout << "be -> BE AZONOSITO" << std::endl;
    }
;

ki:
    KI kifejezes
    {
        std::cout << "ki -> KI kifejezes" << std::endl;
    }
;

elagazas:
    HA kifejezes AKKOR utasitas utasitaslista HA_VEGE
    {
        std::cout << "elagazas -> HA kifejezes AKKOR utasitaslista HA_VEGE" << std::endl;
    }
|
    HA kifejezes AKKOR utasitas utasitaslista KULONBEN utasitas utasitaslista HA_VEGE
    {
        std::cout << "elagazas -> HA kifejezes AKKOR utasitaslista KULONBEN utasitaslista HA_VEGE" << std::endl;
    }
;

ciklus:
    CIKLUS AMIG kifejezes utasitas utasitaslista CIKLUS_VEGE
    {
        std::cout << "ciklus -> CIKLUS AMIG kifejezes utasitaslista CIKLUS_VEGE" << std::endl;
    }
;

kifejezes:
    SZAMKONSTANS
    {
        std::cout << "kifejezes -> SZAMKONSTANS" << std::endl;
		$$ = new Tipus(Egesz);
    }
|
    IGAZ
    {
        std::cout << "kifejezes -> IGAZ" << std::endl;
		$$ = new Tipus(Logikai);
    }
|
    HAMIS
    {
        std::cout << "kifejezes -> HAMIS" << std::endl;
		$$ = new Tipus(Logikai);
    }
|
    AZONOSITO
    {
        std::cout << "kifejezes -> AZONOSITO" << std::endl;
	if(szimbolumtabla.count(*$1) == 0)
	{
		error((std::string("Nem definialt valtozo: " + *$1).c_str()));
		exit(1);
	}
	$$ = new Tipus(szimbolumtabla[*$1].ktip);
	delete $1;
    }
|
    kifejezes PLUSZ kifejezes
    {
        std::cout << "kifejezes -> kifejezes PLUSZ kifejezes" << std::endl;
	if( *$1 != Egesz || *$3 != Egesz)
        {
            std::cerr << "Az összeadás művelet csak két egész esetén végezhető el.";
            exit(1);
        }
        $$ = new Tipus(Egesz);
        delete $1;
        delete $3;
    }
|
    kifejezes MINUSZ kifejezes
    {
        std::cout << "kifejezes -> kifejezes MINUSZ kifejezes" << std::endl;
	if( *$1 != Egesz || *$3 != Egesz)
        {
            std::cerr << "A kivonás művelet csak két egész esetén végezhető el.";
            exit(1);
        }
        $$ = new Tipus(Egesz);
        delete $1;
        delete $3;
    }
|
    kifejezes SZORZAS kifejezes
    {
        std::cout << "kifejezes -> kifejezes SZORZAS kifejezes" << std::endl;
	if( *$1 != Egesz || *$3 != Egesz)
        {
            std::cerr << "A szorzás művelet csak két egész esetén végezhető el.";
            exit(1);
        }
        $$ = new Tipus(Egesz);
        delete $1;
        delete $3;

    }
|
    kifejezes OSZTAS kifejezes
    {
        std::cout << "kifejezes -> kifejezes OSZTAS kifejezes" << std::endl;
	if( *$1 != Egesz || *$3 != Egesz)
        {
            std::cerr << "Az osztás művelet csak két egész esetén végezhető el.";
            exit(1);
        }
        $$ = new Tipus(Egesz);
        delete $1;
        delete $3;

    }
|
    kifejezes MARADEK kifejezes
    {
        std::cout << "kifejezes -> kifejezes MARADEK kifejezes" << std::endl;
	if( *$1 != Egesz || *$3 != Egesz)
        {
            std::cerr << "Az maradékos osztás művelet csak két egész esetén végezhető el.";
            exit(1);
        }
        $$ = new Tipus(Egesz);
        delete $1;
        delete $3;
    }
|
    kifejezes KISEBB kifejezes
    {
        std::cout << "kifejezes -> kifejezes KISEBB kifejezes" << std::endl;
	if( *$1 != *$3 )
        {
            std::cerr << "A kisebb operátor csak két ugyanolyan típusú kifejezést tud összehasonlítani.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;
    }
|
    kifejezes NAGYOBB kifejezes
    {
        std::cout << "kifejezes -> kifejezes NAGYOBB kifejezes" << std::endl;
	if( *$1 != *$3 )
        {
            std::cerr << "A nagyobb operátor csak két ugyanolyan típusú kifejezést tud összehasonlítani.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;
    }
|
    kifejezes KISEBBEGYENLO kifejezes
    {
        std::cout << "kifejezes -> kifejezes KISEBB kifejezes" << std::endl;
	if( *$1 != *$3 )
        {
            std::cerr << "A kisebbegyenlő operátor csak két ugyanolyan típusú kifejezést tud összehasonlítani.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;
    }
|
    kifejezes NAGYOBBEGYENLO kifejezes
    {
        std::cout << "kifejezes -> kifejezes NAGYOBB kifejezes" << std::endl;
	if( *$1 != *$3 )
        {
            std::cerr << "A nagyobbegyenlő operátor csak két ugyanolyan típusú kifejezést tud összehasonlítani.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;

    }
|
    kifejezes EGYENLO kifejezes
    {
        std::cout << "kifejezes -> kifejezes EGYENLO kifejezes" << std::endl;
	if( *$1 != *$3 )
        {
            std::cerr << "Az egyenlő operátor csak két ugyanolyan típusú kifejezést tud összehasonlítani.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;
    }
|
    kifejezes ES kifejezes
    {
        std::cout << "kifejezes -> kifejezes ES kifejezes" << std::endl;
	if( *$1 != Logikai || *$3 != Logikai)
        {
            std::cerr << "Az ÉS kötőszó csak két logikai kifejezés esetén alkalmazható.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;
    }
|
    kifejezes VAGY kifejezes
    {
        std::cout << "kifejezes -> kifejezes VAGY kifejezes" << std::endl;
	if( *$1 != Logikai || *$3 != Logikai)
        {
            std::cerr << "A VAGY kötőszó csak két logikai kifejezés esetén alkalmazható.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $1;
        delete $3;
    }
|
    NEM kifejezes
    {
        std::cout << "kifejezes -> NEM kifejezes" << std::endl;
	if( *$2 != Logikai )
        {
            std::cerr << "Az NEM negáció csak logikai kifejezésre vonatkozhat.";
            exit(1);
        }
        $$ = new Tipus(Logikai);
        delete $2;
    }
|
    BALZAROJEL kifejezes JOBBZAROJEL
    {
        std::cout << "kifejezes -> BALZAROJEL kifejezes JOBBZAROJEL" << std::endl;
	$$ = $2;
    }
;
