From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 14 Jan 2019 09:58:52 +0000
Subject: Re: [PATCH 14/15] arch: add split IPC system calls where needed
Message-Id: <87muo31rxf.fsf@concordia.ellerman.id.au>
List-Id: <linux-ia64.vger.kernel.org>
References: <20190110162435.309262-1-arnd@arndb.de> <20190110162435.309262-15-arnd@arndb.de> <87pnsz28k2.fsf@concordia.ellerman.id.au>
In-Reply-To: <87pnsz28k2.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1254"
Content-Transfer-Encoding: base64
To: y2038@lists.linaro.org, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>, ink@jurassic.park.msu.ru, mattst88@gmail.com, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, tony.luck@intel.com, fenghua.yu@intel.com, geert@linux-m68k.org, monstr@monstr.eu, paul.burton@mips.com, deller@gmx.de, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, dalias@libc.org, davem@davemloft.net, luto@kernel.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, jcmvbkbc@gmail.com, firoz.khan@linaro.org, ebiederm@xmission.com, deepa.kernel@gmail.com, linux@dominikbrodowski.net, akpm@linux-foundation.org, dave@stgolabs.net, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@vger.kernel.org, linux-parisc@vger.kernel.orgl

TWljaGFlbCBFbGxlcm1hbiA8bXBlQGVsbGVybWFuLmlkLmF1PiB3cml0ZXM6Cj4gSGkgQXJuZCwK
Pgo+IEFybmQgQmVyZ21hbm4gPGFybmRAYXJuZGIuZGU+IHdyaXRlczoKPj4gVGhlIElQQyBzeXN0
ZW0gY2FsbCBoYW5kbGluZyBpcyBoaWdobHkgaW5jb25zaXN0ZW50IGFjcm9zcyBhcmNoaXRlY3R1
cmVzLAo+PiBzb21lIHVzZSBzeXNfaXBjLCBzb21lIHVzZSBzZXBhcmF0ZSBjYWxscywgYW5kIHNv
bWUgdXNlIGJvdGguICBXZSBhbHNvCj4+IGhhdmUgc29tZSBhcmNoaXRlY3R1cmVzIHRoYXQgcmVx
dWlyZSBwYXNzaW5nIElQQ182NCBpbiB0aGUgZmxhZ3MsIGFuZAo+PiBvdGhlcnMgdGhhdCBzZXQg
aXQgaW1wbGljaXRseS4KLi4uCj4KPiBXZSBhbHJlYWR5IGhhdmUgYSBnYXAgYXQgMzY2LTM3NyBm
cm9tIHdoZW4gd2UgdHJpZWQgdG8gYWRkIHRoZSBzcGxpdCBJUEMKPiBjYWxscyBhIGZldyB5ZWFy
cyBiYWNrLgo+Cj4gSSBndWVzcyBJIGRvbid0IG1pbmQgbGVhdmluZyB0aGF0IGdhcCBhbmQgdXNp
bmcgdGhlIGNvbW1vbiBudW1iZXJzIGFzCj4geW91J3ZlIGRvbmUgaGVyZS4KPgo+IEJ1dCBpdCB3
b3VsZCBiZSBnb29kIHRvIGFkZCBhIGNvbW1lbnQgcG9pbnRpbmcgb3V0IHRoYXQgd2UgaGF2ZSBy
b29tCj4gYXQgMzY2IGZvciBtb3JlIGFyY2ggc3BlY2lmaWMgc3lzY2FsbHMgYXMgd2VsbC4KPgo+
IGNoZWVycwoKR3Vlc3MgSSBzZW50IHRoYXQgb25lIHR3aWNlLiDwn6SmCgpjaGVlcnM=
