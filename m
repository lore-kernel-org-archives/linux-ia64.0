From: Jesse Barnes <jbarnes@engr.sgi.com>
Date: Wed, 23 Jun 2004 17:03:56 +0000
Subject: Re: BUG 2.6.7 hangs on boot (rx2600)
Message-Id: <200406231303.56583.jbarnes@engr.sgi.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_8fb2ARr/7I9OaTJ"
List-Id: <linux-ia64.vger.kernel.org>
References: <20040622061505.GA23075@cup.hp.com>
In-Reply-To: <20040622061505.GA23075@cup.hp.com>
To: linux-ia64@vger.kernel.org


--Boundary-00=_8fb2ARr/7I9OaTJ
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Wednesday, June 23, 2004 10:26 am, Tian, Kevin wrote:
> I'm suspecting line in ia64_switch_to:
> 	/*
> 	* If we've already mapped this task's page, we can skip doing it
> again.
> 	*/
> (p6)	cmp.eq p7,p6=r27,r27 <----- Should here cmp.eq.unc be used
> instead? No time to test it now...

Thanks a lot Kevin, that worked great!  Here's the patch for people who want 
something a little easier to apply.  Too bad the init_task move patch was 
mixed up with some ia32 stuff or it would have been easier to revert this 
change for testing.

Clear both p7 and p6 predicates in the check for task struct mapping in 
ia64_switch_to.

Jesse

--Boundary-00=_8fb2ARr/7I9OaTJ
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="init-task-move-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="init-task-move-fix.patch"

===== arch/ia64/kernel/entry.S 1.61 vs edited =====
--- 1.61/arch/ia64/kernel/entry.S	2004-06-16 21:09:33 -04:00
+++ edited/arch/ia64/kernel/entry.S	2004-06-23 12:47:37 -04:00
@@ -191,7 +191,7 @@
 	/*
 	 * If we've already mapped this task's page, we can skip doing it again.
 	 */
-(p6)	cmp.eq p7,p6=r26,r27
+(p6)	cmp.eq.unc p7,p6=r26,r27
 (p6)	br.cond.dpnt .map
 	;;
 .done:

--Boundary-00=_8fb2ARr/7I9OaTJ--
