From: Tom King <Tom.King@bullant.com>
Date: Thu, 08 Mar 2001 03:45:15 +0000
Subject: RE: [linux-ia64] re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005264@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

just remove all the couts and see what happens - "cout is like printf"
the problem is that the exception handling does not work -
I copied the gcc 3 prerelease and will build it (I don't have all the source
yet)


>I don't know what "NYI" means.

>> The format of the data is documented in the Software Conventions and
Runtime
>> Architecture manual, section 11.  The library interface for C++ EH is
>> documented in the psABI, section 6.  This hasn't been implemented yet, we
are
>> working on it right now.

NYI not yet implemented. I assumed that possibly this might be the reason
why it wasn't working

# throws.h
#include <stdlib.h>
class exc {
  private :
    int level;
  public :

  void setLevel(int il) { level = il; }
  int getLevel() { return level; }
  };
void doit(int, int);
void doit2(int, int);
//--------------------------------------------------------------------------
//throws.cpp

#include "throws.h"
int main(int argc, char ** argv, char **envp)
{
  int count = atoi(*(argv+1));
  try {
    doit(count, count);
  } 
  catch(exc e) {
  }
}

void doit(int start, int level) {
  if (level = 0 ) {
    exc e;
    e.setLevel(start);
    throw(e);
  } 
  else {
    doit(start, level - 1);
  }
}

