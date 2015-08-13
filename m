From: Christoph Hellwig <hch@lst.de>
Date: Thu, 13 Aug 2015 14:31:50 +0000
Subject: Re: [PATCH 29/31] parisc: handle page-less SG entries
Message-Id: <20150813143150.GA17183@lst.de>
List-Id: <linux-ia64.vger.kernel.org>
References: <1439363150-8661-1-git-send-email-hch@lst.de> <1439363150-8661-30-git-send-email-hch@lst.de> <CA+55aFxsH9Lde7wqZi555vqfH2uxeQqC9cjeca9L6Wr=XpyzXA@mail.gmail.com>
In-Reply-To: <CA+55aFxsH9Lde7wqZi555vqfH2uxeQqC9cjeca9L6Wr=XpyzXA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Jens Axboe <axboe@kernel.dk>, Dan Williams <dan.j.williams@intel.com>, Vineet Gupta <vgupta@synopsys.com>, =?iso-8859-1?Q?H=E5vard?= Skinnemoen <hskinnemoen@gmail.com>, Hans-Christian Egtvedt <egtvedt@samfundet.no>, Miao Steven <realmz6@gmail.com>, David Howells <dhowells@redhat.com>, Michal Simek <monstr@monstr.eu>, the arch/x86 maintainers <x86@kernel.org>, David Woodhouse <dwmw2@infradead.org>, Alex Williamson <alex.williamson@redhat.com>, grundler@parisc-linux.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-alpha@vger.kernel.org, "linux-ia64@vger.kernel.org" <linux-ia64@vger.kernel.org>, linux-metag@vger.kernel.org, linux-mips <linux-mips@linux-mips.org>, Parisc List <linux-parisc@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, Linux Media Mailing List <linux-media@vger.kernel.org>

T24gV2VkLCBBdWcgMTIsIDIwMTUgYXQgMDk6MDE6MDJBTSAtMDcwMCwgTGludXMgVG9ydmFsZHMg
d3JvdGU6Cj4gSSdtIGFzc3VtaW5nIHRoYXQgYW55Ym9keSB3aG8gd2FudHMgdG8gdXNlIHRoZSBw
YWdlLWxlc3MKPiBzY2F0dGVyLWdhdGhlciBsaXN0cyBhbHdheXMgZG9lcyBzbyBvbiBtZW1vcnkg
dGhhdCBpc24ndCBhY3R1YWxseQo+IHZpcnR1YWxseSBtYXBwZWQgYXQgYWxsLCBvciBvbmx5IGRv
ZXMgc28gb24gc2FuZSBhcmNoaXRlY3R1cmVzIHRoYXQKPiBhcmUgY2FjaGUgY29oZXJlbnQgYXQg
YSBwaHlzaWNhbCBsZXZlbCwgYnV0IEknZCBsaWtlIHRoYXQgYXNzdW1wdGlvbgo+ICpkb2N1bWVu
dGVkKiBzb21ld2hlcmUuCgpJdCdzIHRlbXBvcmFyaWx5IG1hcHBlZCBieSBrbWFwLWxpa2UgaGVs
cGVycy4gIFRoYXQgY29kZSBpc24ndCBpbgp0aGlzIHNlcmllcy4gVGhlIG1vc3QgcmVjZW50IHZl
cnNpb24gb2YgaXQgaXMgaGVyZToKCmh0dHBzOi8vZ2l0Lmtlcm5lbC5vcmcvY2dpdC9saW51eC9r
ZXJuZWwvZ2l0L2RqYncvbnZkaW1tLmdpdC9jb21taXQvP2g9cGZuJmlk3jgyMzdjOTlmZGI0MzUy
YmUyMTkzZjNhNzYxMGU5MDJiOWJiMmYwCgpub3RlIHRoYXQgaXQncyBub3QgZG9pbmcgdGhlIGNh
Y2hlIGZsdXNoaW5nIGl0IHdvdWxkIGhhdmUgdG8gZG8geWV0LCBidXQKaXQncyBhbHNvIG9ubHkg
ZW5hYmxlZCBmb3IgeDg2IGF0IHRoZSBtb21lbnQuCi0tClRvIHVuc3Vic2NyaWJlIGZyb20gdGhp
cyBsaXN0OiBzZW5kIHRoZSBsaW5lICJ1bnN1YnNjcmliZSBsaW51eC1pYTY0IiBpbgp0aGUgYm9k
eSBvZiBhIG1lc3NhZ2UgdG8gbWFqb3Jkb21vQHZnZXIua2VybmVsLm9yZwpNb3JlIG1ham9yZG9t
byBpbmZvIGF0ICBodHRwOi8vdmdlci5rZXJuZWwub3JnL21ham9yZG9tby1pbmZvLmh0bWw=
