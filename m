From: "Donny Cooper" <dcooper@atcc.necsys.com>
Date: Tue, 06 Nov 2001 20:42:35 +0000
Subject: RE: [Linux-ia64] cpuinfo family changed in 2.4.7
Message-Id: <marc-linux-ia64-105590698805449@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805447@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805447@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

What about the recently added "arch" field for 2.4.7, will it stay consistent in the kernel throughout each chip
generation for Intel 64-bit.

Currently --> arch : IA-64

Thanks.
Donny



-----Original Message-----
From: linux-ia64-admin@linuxia64.org
[mailto:linux-ia64-admin@linuxia64.org]On Behalf Of David Mosberger
Sent: Tuesday, November 06, 2001 10:40 AM
To: dcooper@atcc.necsys.com
Cc: !IA64-Dist-Linuxia64 (E-mail)
Subject: Re: [Linux-ia64] cpuinfo family changed in 2.4.7


>>>>> On Tue, 6 Nov 2001 08:35:01 -0600, "Donny Cooper" <dcooper@atcc.necsys.com> said:

  Donny> Hello, The value of /proc/cpuinfo "family" field has changed
  Donny> in standard IA-64 kernel since 2.4.7.  ("IA-64" -> "Itanium"
  Donny> or "McKinley")

  Donny> Is this field expected any further changes in the future, or
  Donny> are these the final values for this architecture.

"Itanium" is pretty much final.  I'm less certain about McKinley, as
that's just a code name.

	--david

_______________________________________________
Linux-IA64 mailing list
Linux-IA64@linuxia64.org
http://lists.linuxia64.org/lists/listinfo/linux-ia64


