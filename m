From: Matthew Wilcox <willy@debian.org>
Date: Tue, 16 Dec 2003 12:17:57 +0000
Subject: Re: Latest 2.4 IA64 Baseline (Bjorn) + Latest ACPI testing report
Message-Id: <marc-linux-ia64-107157714602657@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106863619315583@msgid-missing>
In-Reply-To: <marc-linux-ia64-106863619315583@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Dec 16, 2003 at 05:37:35PM +0800, Yu, Luming wrote:
> >So we end up with something like this in /proc/ioports (this is a
> >made-up example, but same idea):
> >
> >	000003c0-000003df : vga+
> >	00004000-00009fff : PCI Bus 00:00
> >	  00004000-000040ff : sym53c8xx
> >	  00004100-000041ff : sym53c8xx
> >
> >when we should have this:
> >
> >	00000000-00000cf7 : PCI Bus 00:00
> >	  000003c0-000003df : vga+
> >	00004000-00009fff : PCI Bus 00:00
> >	  00004000-000040ff : sym53c8xx
> >	  00004100-000041ff : sym53c8xx
> >
> >The patch just changes the PCI root bridge allocation so that
> >instead of failing if part of the range has already been allocated,
> >it inserts a new range up one level, so it encloses the previous
> >VGA allocation.
> 
> Could you let me see what are you patch doing.  

I haven't seen Bjorn's patch yet, but it'll be something like:

--- arch/ia64/pci/pci.c 12 Aug 2003 19:10:49 -0000      1.3
+++ arch/ia64/pci/pci.c 16 Dec 2003 12:13:53 -0000
@@ -153,7 +153,7 @@ alloc_resource (char *name, struct resou
        res->end = end;
        res->flags = flags;
 
-       if (request_resource(root, res))
+       if (insert_resource(root, res))
                return -EBUSY;
 
        return 0;


> I think  "To bus device, resources returned from _CRS method means that bus device will
> supply those resouces to its children devices. So it's unreasonable to call
> request_resource for them."

That's faulty logic.  Resources can either be busy (used at the leaf
by a driver) or merely containers for other resources (as they are in
this case).

> I have a patch for above statement.  Please take http://bugzilla.kernel.org/show_bug.cgi?id85 a look.

No.  That will lose the information about which areas are under which
busses, which is rather useful information to have.  For example, when
PCI needs to allocate resources, if we don't partition the root resource
amongst the child busses, we could inadvertently allocate resources that
straddle two PCI busses, and that just won't work.

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
