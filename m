From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 25 Jan 2005 06:30:31 +0000
Subject: RE: bk pull on ia64 linux tree
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F02CA99D3@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
In-Reply-To: <Pine.LNX.4.58.0401121658240.14305@evo.osdl.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>Thanks for adding the export, I don't do modules very often.  
>But does drm really need the #ifdef __ia64__ around the include of efi.h?  
>Isn't that file safe to include unconditionally?

The #ifdef is almost certainly unneeded ... but I wasn't in
a position to even build on more than one other arch on Saturday
when I was catching up.  So rather than risk breaking the build,
I went for the easy way out and added the #ifdef.

-Tony
