From: James Wilson <wilson@wilson.cygnus.com>
Date: Mon, 19 Jun 2000 18:21:05 +0000
Subject: Re: [Linux-ia64] ia-64 backend dependency on c front end
Message-Id: <marc-linux-ia64-105590678205164@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205160@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205160@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

	I discovered this evening that the IA-64 backend (specifically the
	def_builtin() macro) depends on builtin_function() which is located in
	c-decl.c

All front ends must have a function called builtin_function.

Jim


