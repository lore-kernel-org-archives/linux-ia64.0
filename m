From: Peter Chubb <peterc@gelato.unsw.edu.au>
Date: Wed, 25 Aug 2004 22:46:44 +0000
Subject: Re: Long Format VHPT patches
Message-Id: <16685.5844.673016.685073@wombat.chubb.wattle.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040825023439.GA15782@cse.unsw.EDU.AU>
In-Reply-To: <20040825023439.GA15782@cse.unsw.EDU.AU>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> "Arun" = Arun Sharma <arun.sharma@intel.com> writes:

Arun> On 8/25/2004 10:01 AM, Jesse Barnes wrote:
>> On Tuesday, August 24, 2004 7:34 pm, Ian Wienand wrote:
>>> 11-lf-VHPT-kconfig.patch
>>  Given your conclusions in the paper, would it make sense to
>> unconditionally switch to long format VHPT?  It would simplify
>> things a little and maybe avoid some trouble in the future.
>> 

Arun> When the super page optimizations are implemented, long format
Arun> might be a more attractive option. Without it, the increased
Arun> cache footprint of the long format pte is not compensated by the
Arun> benefits on the workloads we tried.


I suggest that we do like we did for the large block device patch ---
enable it unconditionally in the -mm and other test series, then flip
back to a config option in mainline.  That way, anyone using 2.6 for a
production kernel gets a choice, and while we're in test phase, the
patch gets a good workout.

-- 
Dr Peter Chubb  http://www.gelato.unsw.edu.au  peterc AT gelato.unsw.edu.au
The technical we do immediately,  the political takes *forever*
