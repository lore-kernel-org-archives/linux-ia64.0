From: Brent Casavant <bcasavan@sgi.com>
Date: Fri, 20 Jan 2006 16:14:21 +0000
Subject: Re: [PATCH] SN2 user-MMIO CPU migration
Message-Id: <20060120101221.R91550@chenjesu.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060118163305.Y42462@chenjesu.americas.sgi.com>
 <20060120083651.GA3970@elte.hu>
In-Reply-To: <20060120083651.GA3970@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, jes@sgi.com, tony.luck@intel.com

On Fri, 20 Jan 2006, Ingo Molnar wrote:

> hm, why isnt the synchronization done in switch_to()? Your arch-level 
> switch_to() could have something like thread->last_cpu_sync, and if 
> thread->last_cpu_sync != this_cpu, do the flush. This would not only 
> keep this stuff out of the generic scheduler, but it would also optimize 
> things a bit more: the moment we do a set_task_cpu() it does not mean 
> that CPU _will_ run the task. Another CPU could grab that task later on.  

Very good points all around.  I'll rework the changes in just the
manner you mentioned.

Brent

-- 
Brent Casavant                          All music is folk music.  I ain't
bcasavan@sgi.com                        never heard a horse sing a song.
Silicon Graphics, Inc.                    -- Louis Armstrong
