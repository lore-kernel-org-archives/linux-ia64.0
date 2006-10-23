From: Russ Anderson <rja@sgi.com>
Date: Mon, 23 Oct 2006 04:09:39 +0000
Subject: Re: [patch] MCA recovery: Montecito support
Message-Id: <200610230409.k9N49f5D20849375@clink.americas.sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
In-Reply-To: <200610201555.k9KFtnvu20317790@clink.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hidetoshi Seto wrote:
> Russ Anderson wrote:
> > +	/*
> > +	 * Look through the cache checks for a valid target identifier
> > +	 */
> > +	for (i = 0; i < peidx_cache_check_num(peidx); i++) {
> > +		smei = (sal_log_mod_error_info_t *)peidx_cache_check(peidx, i);
> > +		if (smei->valid.target_identifier && smei->target_identifier)
> > +			return smei->target_identifier;
> > +	}
> 
> This says there would be more than 1 cache_check in the sal log.
> I suppose it also means there would be more than 1 identifier.
> Are there any reason why you don't handle identifiers other than
> listed earliest?

My testing has encountered more than one cache check, but not
multiple cache checks with valid target identifiers with different
addresses.  

I guess if there were two different addresses, the level L1 would
be more likely to be the one that triggered the MCA (assuming 
the other was L2).  I'll ask Intel for clarification.

Here are some examples of multiple cache checks.
---------------------------------------------------
  Cache check info[0]
    Operation: 7 (Move in), Level: L1, Line: Data, Cache: Data, Way: 5, Index: 128
    machine check corrected
  Cache check info[1]
    Operation: 1 (Load), Level: L2, Line: Data, Cache: Data
    machine check corrected
    target identifier        : 0x000000600c594000
---------------------------------------------------

  Cache check info[0]
    Operation: 2 (Store), Level: L1, Line: Data, Cache: Data, Way: 7, Index: 0
    target identifier        : 0x0000006046418000
  Cache check info[1]
    Operation: 7 (Move in), Level: L1, Line: Data, Cache: Data, Way: 7, Index: 0

---------------------------------------------------
  Cache check info[0]
    Operation: 7 (Move in), Level: L1, Line: Data, Cache: Data, Way: 0, Index: 128
    machine check corrected
    target identifier        : 0x000000607a524000
  Cache check info[1]
    Operation: 1 (Load), Level: L2, Line: Data, Cache: Data
    machine check corrected
    target identifier        : 0x000000607a524000
---------------------------------------------------

-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com
