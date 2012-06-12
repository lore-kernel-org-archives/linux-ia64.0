From: Petr Tesarik <ptesarik@suse.cz>
Date: Tue, 12 Jun 2012 17:07:03 +0000
Subject: Wrong NaTVal in unw_access_gr ?
Message-Id: <201206121907.04177.ptesarik@suse.cz>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

I've been looking at the following code trying to understand what it does:

					/* simulate getf.sig/setf.sig */
					if (write) {
						if (*nat) {
							/* write NaTVal and be done with it */
							addr[0] = 0;
							addr[1] = 0x1fffe;
							return 0;
						}
						addr[1] = 0x1003e;
					} else {
						if (addr[0] = 0 && addr[1] = 0x1ffe) {
							/* return NaT and be done with it */
							*val = 0;
							*nat = 1;
							return 0;
						}
					}

In particular, I'm puzzled about the "0x1ffe" constant for the read case. 
Shouldn't that be 0x1fffe (with one more 'f'), i.e. the binary representation 
of NaTVal?

Petr Tesarik
