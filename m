From: Tom King <Tom.King@bullant.com>
Date: Wed, 07 Mar 2001 03:51:44 +0000
Subject: Re: [linux-ia64] re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005251@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>2. What is this new unwind stuff?

> You probably want to know in the context of the kernel.  I can't answer
that.

> I can answer in the context of C++.  The unwind stuff is used for
exception
> handling.  When a program throws, we use the unwind stuff to unwind stack
> frames back to where the exception handler (catch clause) is.  The unwind
> data is similar in spirit to the DWARF2 frame info that is currently used
by
> most all other gcc targets.  It is basically the same data just encoded
> differently.
> The format of the data is documented in the Software Conventions and
Runtime
> Architecture manual, section 11.  The library interface for C++ EH is
> documented in the psABI, section 6.  This hasn't been implemented yet, we
are
> working on it right now.

> Jim

This is really a question about throw/catch on g++. I wonder if your
description of NYI is the reason for the failure?
I am running gnupro-1117-6 (gcc version 2.96-ia64-000717 snap 001117)
on Redhat 7.0 fisher (kernel 2.4.0-0.99.11smp) on a lion processor
the following program runs o.k. with ./a.out 5 - but fails with ./a.out 6

# throws.h
#include <iostream>
#include <stdlib.h>
class exc {
  private :
    int level;
  public :

  void setLevel(int il) { level = il; cout << "set exc " << level << "\n"; }
  int getLevel() { return level; }
  void here(){ cout << "exception" ; } 

  };
void doit(int, int);
void doit2(int, int);
//--------------------------------------------------------------------------
---------------------------
//throws.cpp

#include "throws.h"
int main(int argc, char ** argv, char **envp)
{
  int count = atoi(*(argv+1));
  try {
    doit(count, count);
  } 
  catch(exc e) {
    cout << "doit at top level " << e.getLevel() << "\n";
  }
}

void doit(int start, int level) {
  if (level = 0 ) {
    cout << "o.k.\n" ;
    exc e;
    e.setLevel(start);
    throw(e);
  } 
  else {
    doit(start, level - 1);
  }
}
//--------------------------------------------------------------------------
-----------------
bash% g++ -Wall -ggdb -fPIC -fexceptions  -mb-step  throws.cpp
bash% ./a.out 5
o.k.
set exc 5
doit at top level 5
bash% ./a.out 6
o.k.
set exc 6
Illegal instruction (core dumped)

 
Tom King
Kernel Engineer
Bullant Technology
DID +61-2-8925-1618
http://www.bullant.com


