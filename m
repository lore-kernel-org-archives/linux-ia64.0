From: Jack Steiner <steiner@sgi.com>
Date: Fri, 09 May 2003 20:02:47 +0000
Subject: Re: [Linux-ia64] Re: [PATCH] head.S fix for unusual load addrs
Message-Id: <marc-linux-ia64-105590723705709@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705550@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705550@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> >>>>> On Fri, 9 May 2003 10:52:25 -0700, Jesse Barnes <jbarnes@sgi.com> said:
> 
>   Jesse> So, is there any consensus on the best path to pursue?  Chris Wedgwood
>   Jesse> is working on option #3, and I've got Tony's patch trimmed down to #2
>   Jesse> (with one piece missing--ia64_switch_to runtime patching), but none of
>   Jesse> these are in either 2.4 or 2.5 yet.  Maybe for 2.4 we should do #2 or
>   Jesse> #3 and for 2.5 we could implement #1 with the virtual offsets Tony
>   Jesse> mentioned earlier?
> 
> I'm not sure.  I got the impression Tony may be looking at the virtual
> remapping in region 5.  I haven't heard whether text replication
> turned out to be important for 8870, but I'm starting to lean towards
> virtual remapping because it is more versatile (can handle both
> "strange" physical memory layouts and kernel replication).  This,
> coupled with the fact that it doesn't break any of the existing tools
> makes it pretty compelling.  Also, my primary objection about making
> the kernel model more complicated doesn't hold much water if we move
> everything to region 5.
> 
> Would there be a downside to this on SGI's machines?

I dont see any significant problems. It actually seems easy.

I think we still need to use __tpa() for addresses assigned by the loader.
The standard __pa() macros wont work in region 5. 

I dont have any objections to __tpa.  We have had them in the kernel 
since ~2.3.42 & have not had any problems with them. On occasion, when 
we upgrade, we have to add/delete a couple of references but these are 
always easy to find. I dont recall any changes for the last couple of upgrades
but maybe we were just lucky.

As I mention in mail earlier, 

>> The __tpa macros are ugly but they are fully contained within the ia64 part
>> of the tree. (IIRC, the old scheduler had a reference but the O(1) scheduler doe not).
>> In our tree, there are currently only 12 references to __tpa. All are
>> in boottime initialization code, mostly in mca.c.  Although I would
>> rather not have __tpa, this doesnt seem too bad.



> 
> 	--david
> 
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
> 


-- 
Thanks

Jack Steiner    (651-683-5302)   (vnet 233-5302)      steiner@sgi.com


