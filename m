From: Jes Sorensen <jes@linuxcare.com>
Date: Fri, 08 Dec 2000 17:53:36 +0000
Subject: Re: [Linux-ia64] Re: Fault 26?
Message-Id: <marc-linux-ia64-105590678205818@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205793@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205793@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Dan" = Dan Pop <Dan.Pop@cern.ch> writes:

Dan> On Wed, 6 Dec 2000, Bill Nottingham wrote:

>> David Mosberger (davidm@hpl.hp.com) said: > Bill> What is fault
>> type 26?  I'm getting a few of these recently.  > > It's the "NaT
>> consumption fault".  Either buggy code is trying to eat > a NaT
>> value or something else goes wrong and a NaT value is created >
>> when it shouldn't be.
>> 
>> It's happening in strcpy(), of all places, with two seemingly valid
>> arguments.

Dan> Here's a patch that should fix it.  The bug was in a recovery
Dan> code that was highly unlikely to be ever executed, hence it
Dan> passed unnoticed for so long :-)

Great

I have applied this to my tree and asked Ulrich to apply it to the
official tree.

Jes

