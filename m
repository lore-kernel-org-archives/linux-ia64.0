From: Dean Roe <roe@sgi.com>
Date: Thu, 02 Feb 2006 21:22:40 +0000
Subject: Re: ia64 printk_clock()
Message-Id: <20060202212240.GA17176@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060202204422.GA27082@sgi.com>
In-Reply-To: <20060202204422.GA27082@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Feb 02, 2006 at 02:44:22PM -0600, Jack Steiner wrote:
> We are seeing kernel hangs in early boot if CONFIG_PRINTK_TIME is
> enabled. The hang is caused by a reference in sched_clock() to 
> the percpu data area before it is initialized. 
> 
> I know there was discussion about this late last summer & I thought
> Tony posted a patch. Does anyone recall the status.
> 
> AFAICT, we see failures on SN systems but other IA64 systems work ok.
> 
> ---
> Jack

Jack, I think this is the thread you are looking for:
    http://marc.theaimsgroup.com/?l=linux-ia64&m2422250517703&w=2

Dean

-- 
Dean Roe
Silicon Graphics, Inc.
roe@sgi.com
