From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Date: Thu, 02 Nov 2006 19:50:08 +0000
Subject: RE: [PATCH]IA64 trap code 16 bytes atomic copy on montecito, take 2
Message-Id: <000001c6feb8$19f14e40$ff0da8c0@amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <454961EE.4070608@intel.com>
In-Reply-To: <454961EE.4070608@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Keshavamurthy, Anil wrote on Thursday, November 02, 2006 11:39 AM
> > > > Do you allow kprobe insertion on "L+X" instruction?  It looks like so.
> > > > Then how do you maintain atomic update to L and X instruction right
> > > > now with memcpy?
> 
> 	Instruction Type "L+X" take two instruction slots i.e slot 1 and slot 2,
> but we only modify slot 2 to insert or remove the break and slot 2 nicely
> happens to be in the upper 8 bytes of the instruction bundle. So we don't have any
> issues here. For either inserting or removing break for "L+X" we don;t modify Slot 1
> value at all.

I wasn't aware that X slot can be encoded with break.i.  In that case, yes,
only slot 2 is modified and everything is fine. I guess the compatibility
mode saves the day for patching "L+X".

