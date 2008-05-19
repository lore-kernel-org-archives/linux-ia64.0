From: Avi Kivity <avi@qumranet.com>
Date: Mon, 19 May 2008 10:31:35 +0000
Subject: Re: ld2.acq - sign extension?
Message-Id: <48315707.4020805@qumranet.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <yq0wslqiqyp.fsf@jaguar.mkp.net>
In-Reply-To: <yq0wslqiqyp.fsf@jaguar.mkp.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Jes Sorensen wrote:
> Andreas Schwab wrote:
>> Jes Sorensen <jes@sgi.com> writes:
>>
>>> Basically if I apply the below diff my code no longer works. However I
>>> am under the impression that ld2.acq does sign extension?
>>
>> ld always zero extends.
>
> Hi Andreas,
>
> Thats what I thought too, but do you have any explanation as to why
> that patch I included makes a difference?
>

r17 is used later on, so your patch makes it uninitialized (if I may 
venture to comment about an assembly language I know nothing about).

Maybe a bug in the instruction emulator?

-- 
error compiling committee.c: too many arguments to function

