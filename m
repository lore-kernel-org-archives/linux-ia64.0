From: "Randy.Dunlap" <rddunlap@osdl.org>
Date: Tue, 06 Apr 2004 22:52:12 +0000
Subject: Re: hardware random number generator?
Message-Id: <20040406155212.2ae9fdb5.rddunlap@osdl.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <405F9A2E.8040509@pobox.com>
In-Reply-To: <405F9A2E.8040509@pobox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 23 Mar 2004 23:23:29 -0800 Mallick, Asit K wrote:

| E8870 based McKinley/Madison platforms does have ICH4. It is used to
| provide USB, IDE, On board LAN, LPC, SMBus, etc. funtionality. However,
| the RNG does not work on current E8870 based platforms. Future platforms
| may enable RNG.

Does this agree with or allow for this end-of-support announcement?
http://www.intel.com/design/security/rng/rng.htm


| Thanks,
| Asit
| 
| >-----Original Message-----
| >From: linux-ia64-owner@vger.kernel.org 
| >[mailto:linux-ia64-owner@vger.kernel.org] On Behalf Of Matthew Wilcox
| >Sent: Monday, March 22, 2004 7:05 PM
| >To: Jeff Garzik
| >Cc: Matthew Wilcox; linux-ia64@vger.kernel.org
| >Subject: Re: hardware random number generator?
| >
| >On Mon, Mar 22, 2004 at 09:00:14PM -0500, Jeff Garzik wrote:
| >> Matthew Wilcox wrote:
| >> >config HW_RANDOM
| >> >        tristate "Intel/AMD/VIA HW Random Number Generator support"
| >> >        depends on (X86 || IA64) && PCI
| >> >        ---help---
| >> >          This driver provides kernel-side support for the 
| >Random Number
| >> >          Generator hardware found on Intel i8xx-based motherboards,
| >> >          AMD 76x-based motherboards, and Via Nehemiah CPUs.
| >> >
| >> >Why IA64 too?  This file contains the code:
| >> 
| >> No idea.  <guessing>  There are some Intel ICH-based motherboards w/ 
| >> IA64 chips on them, maybe?  I certainly don't recall adding 
| >that IA64 
| >> marker... :)
| >
| >Heh.  ICH is x86-only, as far as I know.  Intel did the 460GX chipset
| >for Merced and now have the E8870 chipset for McKinley/Madison.  Anyone
| >familiar with the Intel chipsets want to comment about the presence or
| >absence of a RNG?
| >
| >-- 


--
~Randy
"We have met the enemy and he is us."  -- Pogo (by Walt Kelly)
(Again.  Sometimes I think ln -s /usr/src/linux/.config .signature)
