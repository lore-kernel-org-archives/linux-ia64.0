From: Matthew Wilcox <willy@debian.org>
Date: Thu, 18 Mar 2004 23:51:37 +0000
Subject: [1/3] insert_resource can succeed and return an error
Message-Id: <20040318235137.GI25059@parcelfarce.linux.theplanet.co.uk>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040318235024.GH25059@parcelfarce.linux.theplanet.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Matthew Wilcox <willy@debian.org>
Cc: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@zip.com.au>, Greg KH <greg@kroah.com>, David Mosberger <davidm@hpl.hp.com>, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org


If we start again, we can return an error even if we were successful.
Reset the result to 0 before beginning again.  Why don't we use a
tailcall here?

Index: kernel/resource.c
=================================RCS file: /var/cvs/linux-2.6/kernel/resource.c,v
retrieving revision 1.12
diff -u -p -r1.12 resource.c
--- a/kernel/resource.c	28 Feb 2004 01:51:35 -0000	1.12
+++ b/kernel/resource.c	18 Mar 2004 23:41:01 -0000
@@ -337,6 +337,7 @@ int insert_resource(struct resource *par
 	/* existing resource overlaps end of new resource */
 	if (next->end > new->end) {
 		parent = next;
+		result = 0;
 		goto begin;
 	}
 

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
