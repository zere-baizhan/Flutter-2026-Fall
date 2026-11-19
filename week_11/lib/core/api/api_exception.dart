sealed class ApiException implements Exception { 

  const ApiException(); 

} 
class NoConnectionException extends ApiException { 

  const NoConnectionException(); 

} 

class ServerException extends ApiException { 
//5xx
  const ServerException(this.status); 

  final int status; 

} 

  

class NotFoundException extends ApiException { 
//404
  const NotFoundException(); 

} 

  

class UnauthorizedException extends ApiException { 
//401
  const UnauthorizedException(); 

} 

  


class BadResponseException extends ApiException { 

  const BadResponseException([this.detail]); 

  final String? detail; 
  @override
  String toString() => 'BadResponseException($detail)';

} 