From: Gerald Pfeifer <gp@suse.de>
Date: Mon, 09 May 2005 21:54:28 +0000
Subject: Re: Divide by zero works on ia64!!!
Message-Id: <Pine.LNX.4.61.0505092341090.16363@lifschitz.suse.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1115652187.28663.4.camel@lyra.fc.hp.com>
In-Reply-To: <1115652187.28663.4.camel@lyra.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Mon, 9 May 2005, Khalid Aziz wrote:
>> Nothing.  Divide by zero is undefined.
> So, is the inconsistency between x86 and ia64 okay?

Why not?  Even an application as simple as the following will give a 
different output on x86 and ia64:

  #include <iostream>
  #include <climits>

  using namespace std;

  int main() {
    cout << "sizeof long = " << sizeof(long) << endl
         << "CHAR_MAX = " << CHAR_MAX << endl;
  }

And when you run this on ppc64, the output will not match either one
of the above, and on s390 it's different again, yet products like SLES 
support all three (and further) architectures with a common codebase.

Gerald
