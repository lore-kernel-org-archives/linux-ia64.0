From: Kalle Valo <kvalo@kernel.org>
Date: Mon, 28 Mar 2022 09:33:42 +0000
Subject: Re: [PATCH 00/22] Replace comments with C99 initializers
Message-Id: <87fsn2zaix.fsf@kernel.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
        <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz>
In-Reply-To: <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz> ("Benjamin
        \=\?utf-8\?Q\?St\=C3\=BCrz\=22's\?\= message of "Sun, 27 Mar 2022 14:46:00 +0200")
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: Benjamin =?utf-8?Q?St=C3=BCrz?= <benni@stuerz.xyz>
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

QmVuamFtaW4gU3TDvHJ6IDxiZW5uaUBzdHVlcnoueHl6PiB3cml0ZXM6Cgo+IFRoaXMgcGF0Y2gg
c2VyaWVzIHJlcGxhY2VzIGNvbW1lbnRzIHdpdGggQzk5J3MgZGVzaWduYXRlZCBpbml0aWFsaXpl
cnMKPiBpbiBhIGZldyBwbGFjZXMuIEl0IGFsc28gYWRkcyBzb21lIGVudW0gaW5pdGlhbGl6ZXJz
LiBUaGlzIGlzIG15IGZpcnN0Cj4gdGltZSBjb250cmlidXRpbmcgdG8gdGhlIExpbnV4IGtlcm5l
bCwgdGhlcmVmb3JlIEknbSBwcm9iYWJseSBkb2luZyBhCj4gbG90IG9mIHRoaW5ncyB0aGUgd3Jv
bmcgd2F5LiBJJ20gc29ycnkgZm9yIHRoYXQuCgpKdXN0IGEgc21hbGwgdGlwOiBJZiB5b3UgYXJl
IG5ldywgc3RhcnQgd2l0aCBzb21ldGhpbmcgc21hbGwgYW5kIGxlYXJuCmZyb20gdGhhdC4gRG9u
J3QgZG8gYSBjb250cm92ZXJzaWFsIGJpZyBwYXRjaHNldCBzcGFubmluZyBtdWx0aXBsZQpzdWJz
eXN0ZW1zLCB0aGF0J3MgdGhlIGhhcmQgd2F5IHRvIGxlYXJuIHRoaW5ncy4gRmlyc3Qgc3VibWl0
IG9uZSBwYXRjaAphdCBhIHRpbWUgdG8gb25lIHN1YnN5c3RlbSBhbmQgZ2FpbiB1bmRlcnN0YW5k
aW5nIG9mIHRoZSBwcm9jZXNzIHRoYXQKd2F5LgoKLS0gCmh0dHBzOi8vcGF0Y2h3b3JrLmtlcm5l
bC5vcmcvcHJvamVjdC9saW51eC13aXJlbGVzcy9saXN0LwoKaHR0cHM6Ly93aXJlbGVzcy53aWtp
Lmtlcm5lbC5vcmcvZW4vZGV2ZWxvcGVycy9kb2N1bWVudGF0aW9uL3N1Ym1pdHRpbmdwYXRjaGVz
