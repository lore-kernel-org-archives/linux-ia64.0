From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Wed, 29 Mar 2006 18:23:49 +0000
Subject: RE: gate.S and recent toolchains
Message-Id: <200603291823.k2TIN4g09945@unix-os.sc.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <442AB0DE.1040409@sgi.com>
In-Reply-To: <442AB0DE.1040409@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote on Wednesday, March 29, 2006 10:03 AM
>>>> Basically I am unable to build a kernel from Linus' git tree on one
>>>> system since Monday morning, whereas it boots fine if I build it on an
>>>> older system. I tried installing an older toolchain on this box but it
>>>> still didn't seem to make a difference. The system boots, calls init and
>>>> I most often get the message "INIT: 2.85 booting", then a hang. In some
>>>> instances I don't even get the INIT message.
>>> It builds and boots on all the machines I have tried,
>>> including the same build and boot machines Jes uses.
>>> Jes can't get it to work, I can't get it to fail.
>> 
>> Russ, do you reference __mca_table at run time?  It looks like so.  It's
>> problematic that __mca_table is in __init section.  Though I doubt that
>> was the reason Jes ran into.
>
>I actually noticed that earlier and tried moving it around, but it made
>no difference. I forgot it again in the noise.

That's what I thought as well, very unlikely it is the issue you ran into.

- Ken
