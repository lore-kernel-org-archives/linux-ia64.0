From: Xavier Bru <xavier.bru@bull.net>
Date: Fri, 05 Dec 2003 07:21:44 +0000
Subject: Re: Problem booting Adaptec Ultra 320 driver with discontigmem support.
Message-Id: <marc-linux-ia64-107060900131703@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-107054139923799@msgid-missing>
In-Reply-To: <marc-linux-ia64-107054139923799@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: linux-ia64@vger.kernel.org

The driver dynamically tests the size of the memory and sets the=20
appropriate dma_mask to: 32, 39 or 64 bits (probably dues to historical=20
reasons).
Problem is that with 32 GB of memory installed in a 1 TB physical=20
address space the 39 bit mask is used instead
of the 64-bit mask.

--=20

 Sinc=E8res salutations.
_____________________________________________________________________
=20
Xavier BRU                 BULL ISD/R&D/INTEL office:     FREC B1-422
tel : +33 (0)4 76 29 77 45                    http://www-frec.bull.fr
fax : +33 (0)4 76 29 77 70                 mailto:Xavier.Bru@bull.net
addr: BULL, 1 rue de Provence, BP 208, 38432 Echirolles Cedex, FRANCE
_____________________________________________________________________


