From: =?UTF-8?Q?Benjamin_St=c3=bcrz?= <benni@stuerz.xyz>
Date: Sun, 27 Mar 2022 12:46:00 +0000
Subject: [PATCH 00/22] Replace comments with C99 initializers
Message-Id: <8f9271b6-0381-70a9-f0c2-595b2235866a@stuerz.xyz>
List-Id: <linux-ia64.vger.kernel.org>
References: <20220326165909.506926-1-benni@stuerz.xyz>
In-Reply-To: <20220326165909.506926-1-benni@stuerz.xyz>
MIME-Version: 1.0
Content-Type: text/plain; charset="macroman"
Content-Transfer-Encoding: base64
To: =?UTF-8?Q?Benjamin_St=c3=bcrz?= <benni@stuerz.xyz>
Cc: sebastian.hesselbarth@gmail.com, gregory.clement@bootlin.com, linux@armlinux.org.uk, linux@simtec.co.uk, krzk@kernel.org, alim.akhtar@samsung.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de, dave.hansen@linux.intel.com, hpa@zytor.com, robert.moore@intel.com, rafael.j.wysocki@intel.com, lenb@kernel.org, 3chas3@gmail.com, laforge@gnumonks.org, arnd@arndb.de, gregkh@linuxfoundation.org, mchehab@kernel.org, tony.luck@intel.com, james.morse@arm.com, rric@kernel.org, linus.walleij@linaro.org, brgl@bgdev.pl, mike.marciniszyn@cornelisnetworks.com, dennis.dalessandro@cornelisnetworks.com, jgg@ziepe.ca, pali@kernel.org, dmitry.torokhov@gmail.com, isdn@linux-pingi.de, benh@kernel.crashing.org, fbarrat@linux.ibm.com, ajd@linux.ibm.com, davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, nico@fluxnic.net, loic.poulain@linaro.org, kvalo@kernel.org, pkshih@realtek.com, bhelgaas@google.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, devel@acpica.org, linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org, linux-edac@vger.kernel.org, linux-gpio@vger.kernel.org, linux-rdma@vger.kernel.org, linux-input@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-media@vger.kernel.org, wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org, linux-pci@vger.kernel.org

VGhpcyBwYXRjaCBzZXJpZXMgcmVwbGFjZXMgY29tbWVudHMgd2l0aCBDOTkncyBkZXNpZ25hdGVk
IGluaXRpYWxpemVycwppbiBhIGZldyBwbGFjZXMuIEl0IGFsc28gYWRkcyBzb21lIGVudW0gaW5p
dGlhbGl6ZXJzLiBUaGlzIGlzIG15IGZpcnN0CnRpbWUgY29udHJpYnV0aW5nIHRvIHRoZSBMaW51
eCBrZXJuZWwsIHRoZXJlZm9yZSBJJ20gcHJvYmFibHkgZG9pbmcgYQpsb3Qgb2YgdGhpbmdzIHRo
ZSB3cm9uZyB3YXkuIEknbSBzb3JyeSBmb3IgdGhhdC4KCkkndmUgZ290dGVuIGEgZmV3IGVtYWls
cyBzbyBmYXIgc3RhdGluZyB0aGF0IHRoaXMgcGF0Y2ggc2VyaWVzIGlzCnVubmVjZXNzYXJ5LiBZ
ZXMsIGluIGZhY3QgdGhpcyBwYXRjaCBzZXJpZXMgaXMgbm90IG5lY2Vzc2FyeSBieSBpdHNlbGYs
CmJ1dCBpdCBjb3VsZCBoZWxwIG1lIHVuZGVyc3RhbmQgaG93IHRoZSB3aG9sZSBwcm9jZXNzIHdv
cmtzIGFuZCBtYXliZSBJCmNvdWxkIGhlbHAgc29tZXdoZXJlLCB3aGVyZSBoZWxwIGlzIGFjdHVh
bGx5IG5lZWRlZC4KClRoaXMgcGF0Y2ggaXRzZWxmIGlzIGEgbm8tb3AuCgpTaWduZWQtb2ZmLWJ5
OiBCZW5qYW1pbiBTdMO8cnogPGJlbm5pQHN0dWVyei54eXo+Ci0tLQogLmdpdGlnbm9yZSB8IDIg
Ky0KIDEgZmlsZSBjaGFuZ2VkLCAxIGluc2VydGlvbigrKSwgMSBkZWxldGlvbigtKQoKZGlmZiAt
LWdpdCBhLy5naXRpZ25vcmUgYi8uZ2l0aWdub3JlCmluZGV4IDdhZmQ0MTJkYWRkMi4uNzA2ZjY2
NzI2MWViIDEwMDY0NAotLS0gYS8uZ2l0aWdub3JlCisrKyBiLy5naXRpZ25vcmUKQEAgLTIwLDcg
KzIwLDcgQEAKICouZHRiCiAqLmR0Ym8KICouZHRiLlMKLSouZHdvCisqLmR3bwogKi5lbGYKICou
Z2NubwogKi5negotLSAKMi4zNS4x
