From: Peter Chubb <peter@chubb.wattle.id.au>
Date: Fri, 31 Jan 2003 01:46:00 +0000
Subject: [Linux-ia64] Script for decoding PSR in oopses
MIME-Version: 1
Content-Type: multipart/mixed; boundary="UgleAkwT+h"
Message-Id: <marc-linux-ia64-105590709805784@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
To: linux-ia64@vger.kernel.org

--UgleAkwT+h
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


hi,
	I find trying to work out what the PSR is after an oops to be
a bit of a pain, so here's an awk script to do it for you.

Usage is
      decode_psr hex_number
if you save the script as decode_psr.


--UgleAkwT+h
Content-Type: text/plain
Content-Disposition: inline;
	filename="decode_psr"
Content-Transfer-Encoding: 7bit

#!/bin/sh
echo $1 | awk '



function readhex(hexval,  i, digits, value, ndigit) {
	 tolower(hexval);

	 ndigit = gsub("[a-f0-9]", " &", hexval);
	 split(hexval, digits, " ");


	 value = 0;
	 for ( i = 1; i <= ndigit; i++) {
	     value *= 16;
	     value += values[digits[i]];
	 }
	 return value;
}

function decode_psr(psr,   decoded, cpl) {
	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = "be "
	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = decoded "up "
	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = decoded "ac "
	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = decoded "mfl "
	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = decoded "mfh "
	 psr = int(psr / 256);
	 if (psr % 2)
	    decoded = decoded "ic "

	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = decoded "i "
	 psr = int(psr / 2);
	 if (psr % 2 == 1)
	    decoded = decoded "pk "
	 psr = int(psr / 4)
	 if (psr % 2 == 1)
	    decoded = decoded "dt "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "dfl "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "dfh "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "sp "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "pp "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "di "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "si "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "db "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "lb "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "tb "
	 psr = int(psr / 2)
	 if (psr % 2 == 1)
	    decoded = decoded "rt "
	 psr = int(psr / 16)

	 cpl = psr % 4;
	 decoded = decoded "cpl=" cpl " "

	 psr = int(psr/4)
	 if (psr % 2)
	    decoded = decoded "IA32 "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "mc "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "it "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "id "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "da "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "dd "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "ss "
	 psr = int(psr / 2)
	 cpl = psr %4
	 decoded= decoded "ri=" cpl " "
	 psr = int(psr / 4)
	 if (psr % 2)
	    decoded = decoded "ed "
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "bn"
	 psr = int(psr / 2)
	 if (psr % 2)
	    decoded = decoded "ia"

	 psr = int(psr / 2)
	 if (psr)
	    decoded = decoded "Reserved = " psr

	 return decoded
}

BEGIN {
      for (i = 0; i < 10; i++)
	  values[i ""] = i;
      values["a"] = 10;	
      values["b"] = 11;	
      values["c"] = 12;	
      values["d"] = 13;	
      values["e"] = 14;	
      values["f"] = 15;	

}

	{ print $1, decode_psr(readhex($1)) }
'



--UgleAkwT+h--

