From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Thu, 13 Nov 2003 22:45:29 +0000
Subject: Re: problem in booting HP zx6000 with stock kernel 2.5.75
Message-Id: <marc-linux-ia64-106876398802218@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106840426422921@msgid-missing>
In-Reply-To: <marc-linux-ia64-106840426422921@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Jesse" = Jesse Barnes <jbarnes@sgi.com> writes:

Jesse> On Thu, Nov 13, 2003 at 02:51:43PM +0000, Matthew Wilcox wrote:
>> Jesse and I discussed this yesterday.  To take advantage of the new
>> multiple-defconfigs scheme in 2.6, what we need to do is:
>> 
>> - Create files called arch/ia64/configs/*_defconfig - To use them,
>> type "make zx1_defconfig" (for example).  - Keep them up to date
>> ...
>> 
>> There's a bikeshed question about which configs to support.  I
>> think the rule is pretty simple -- if someone's willing to step up
>> and maintain the config for a platform, let's put it in.
>> 
>> I'd suggest we want to have defconfig as generic, then add configs/

Are you planning for separate SMP and UP configs?

Peetr C
