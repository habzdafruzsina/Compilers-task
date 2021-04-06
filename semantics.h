#ifndef SEMANTICS_H
#define SEMANTICS_H

#include <string>
#include <iostream>
#include <cstdlib>
#include <map>
#include <sstream>

enum Tipus { Egesz, Logikai };

struct kifejezes_leiro
{
    int sor;
    Tipus ktip;
    kifejezes_leiro( int s, Tipus t ) : sor(s), ktip(t) {}
	kifejezes_leiro() {}
};

#endif //SEMANTICS_H

