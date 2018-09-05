module app.component.user.helper.Password;

import std.digest.md;

string generateSalt()
{
    return "$123*Z";
}

string generateUserPassword(string password, string salt)
{
    auto md5 = new MD5Digest();
    
    ubyte[] hashPassword = md5.digest(password);
    ubyte[] hashSalt = md5.digest(salt);
    ubyte[] hashResult = md5.digest(toHexString!(LetterCase.lower)(hashSalt) ~ toHexString!(LetterCase.lower)(hashPassword));

    return toHexString!(LetterCase.lower)(hashResult);
}
