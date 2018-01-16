From: Petr Mladek <pmladek@suse.com>
Date: Tue, 16 Jan 2018 16:33:01 +0000
Subject: Re: [PATCH 00/13] replace print_symbol() with printk()-s
Message-Id: <20180116163301.lh76kvjheyobjgkp@pathway.suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
In-Reply-To: <20171211125025.2270-1-sergey.senozhatsky@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Mark Salter <msalter@redhat.com>, Tony Luck <tony.luck@intel.com>, David Howells <dhowells@redhat.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Guan Xuetao <gxt@mprc.pku.edu.cn>, Borislav Petkov <bp@alien8.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Vineet Gupta <vgupta@synopsys.com>, Fengguang Wu <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-ia64@vger.kernel.org, linux-am33-list@redhat.com, linux-sh@vger.kernel.org, linux-edac@vger.kernel.org, x86@kernel.org, linux-snps-arc@lists.infradead.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

T24gTW9uIDIwMTgtMDEtMDggMTE6MDk6NDIsIFNlcmdleSBTZW5vemhhdHNreSB3cm90ZToKPiBP
biAoMDEvMDUvMTggMTU6NDIpLCBQZXRyIE1sYWRlayB3cm90ZToKPiA+IAo+ID4gSSBhbSBhbGwg
Zm9yIGl0LiBCdXQgSSB3b3VsZCBwb3N0cG9uZSB0aGlzIHJlbW92YWwgdG8gNC4xNy4KPiA+IFRo
ZSByZWFzb24gaXMgcmF0aGVyIHVnbHkuIDEzdGggcGF0Y2ggaXMgYWxyZWFkeSBpbiBhcmMgdHJl
ZS4KPiA+IFdlIHdvdWxkIG5lZWQgdG8gc2h1ZmZsZSB0aGUgcGF0Y2ggb3IgY29vcmRpbmF0ZSBw
dWxsIHJlcXVlc3RzLgo+IAo+IEpGSSwgdGhlIHBhdGNoIGlzIGluIExpbnVzJ3MgdHJlZSBhcyBv
ZiBub3cgKGQwNzI5YmM2YmVlNzk3ZmIpLgoKR3JlYXQuIEkgaGF2ZSBwdXNoZWQgdGhlIHBhdGNo
IHRoYXQgcmVtb3ZlcyBwcmludGtfc3ltYm9sKCkKaW50byBwcmludGsuZ2l0LCBicmFuY2ggZm9y
LTQuMTYtcHJpbnQtc3ltYm9sLgoKTm90ZSB0aGF0IEkgaGF2ZSB1cGRhdGVkIHRoZSBjb21taXQg
bWVzc2FnZSBzaW1pbGFyIHdheQpsaWtlIEkgZGlkIGZvciB0aGUgb3RoZXIgY29tbWl0cy4gRXNw
ZWNpYWxseSBJIHdhbnRlZAp0byBtZW50aW9uIHdoYXQgaXQgd2FzIG9ic29sZXRlZCBieS4gVGhl
IG1lc3NhZ2UgaXM6CgogIGthbGxzeW1zOiByZW1vdmUgcHJpbnRfc3ltYm9sKCkgZnVuY3Rpb24K
CiAgTm8gbW9yZSBwcmludF9zeW1ib2woKS9fX3ByaW50X3N5bWJvbCgpIHVzZXJzIGxlZnQsIHJl
bW92ZSB0aGVzZQogIHN5bWJvbHMuCgogIEl0IHdhcyBhIHZlcnkgb2xkIEFQSSB0aGF0IGVuY291
cmFnZWQgcGVvcGxlIHVzZSBjb250aW51b3VzIGxpbmVzLgogIEl0IGhhZCBiZWVuIG9ic29sZXRl
ZCBieSAlcFMgZm9ybWF0IHNwZWNpZmllciBpbiBhIG5vcm1hbCBwcmludGsoKQogIGNhbGwuCgoK
U2VlIGFsc28KaHR0cHM6Ly9naXQua2VybmVsLm9yZy9wdWIvc2NtL2xpbnV4L2tlcm5lbC9naXQv
cG1sYWRlay9wcmludGsuZ2l0L2NvbW1pdC8/aD1mb3ItNC4xNi1wcmludC1zeW1ib2wmaWTSMjc5
YzlkN2Y3ZGI3Zjk3NTY3MzY4YmZjNDUzOWIzNDExYWRmOGQKCkJlc3QgUmVnYXJkcywKUGV0cgot
LQpUbyB1bnN1YnNjcmliZSBmcm9tIHRoaXMgbGlzdDogc2VuZCB0aGUgbGluZSAidW5zdWJzY3Jp
YmUgbGludXgtaWE2NCIgaW4KdGhlIGJvZHkgb2YgYSBtZXNzYWdlIHRvIG1ham9yZG9tb0B2Z2Vy
Lmtlcm5lbC5vcmcKTW9yZSBtYWpvcmRvbW8gaW5mbyBhdCAgaHR0cDovL3ZnZXIua2VybmVsLm9y
Zy9tYWpvcmRvbW8taW5mby5odG1s
