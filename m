From: David Mosberger <davidm@hpl.hp.com>
Date: Tue, 05 Dec 2000 00:11:31 +0000
Subject: Re: [Linux-ia64] data sharing in MAS O/S
Message-Id: <marc-linux-ia64-105590678205782@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On 23 Nov 00 00:33:05 EET, Bugra Unalmis <bugra.u@usa.net> said:

  Bugra> hi everybody, Data sharing in Multiple address space O/S is
  Bugra> suppoted by loading the same RID into region registers of
  Bugra> multiple processes. If we are talking about the very same
  Bugra> virtual page to be shared, then in TLB we have the same RID
  Bugra> and VPN that is gonna be mapped to a particular physical
  Bugra> address. How will 2 different processes have the different
  Bugra> access rights with the same VPN and RID or how will the
  Bugra> integrity be supported in this case.

Linux processes may share memory but they never share TLB entries.
This may change in the future, as TLB utilitization would increase
with TLB sharing, but it's a non-trivial change, so it's not going to
happen in the 2.4 series.

	--david

