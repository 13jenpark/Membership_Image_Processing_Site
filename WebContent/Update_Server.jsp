<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-KR">
<title>Insert title here</title>
</head>
<body>
<%@ include file="dbconn.jsp" %>
<%
	//세션에서 아이디 불러오기
	String mem_id = (String) session.getAttribute("mem_id");
	
	//수정페이지에서 기존 비밀번호랑 변경할 비밀번호, 이름 가져오기
	String mem_pw = request.getParameter("mem_pw");
	String mem_pw_d = request.getParameter("mem_pw_d");
	String mem_name = request.getParameter("mem_name");
	
	ResultSet rs = null;
	Statement stmt = conn.createStatement();  // 쿼리 명령문
	// DELETE FROM member WHERE mem_id='bbb';
	
	String mem_pw2 ="";
	String sql = "SELECT mem_pw FROM member WHERE mem_id='";
	sql += mem_id +"'";
	rs=stmt.executeQuery(sql);
	
	//DB에서 비밀번호 가져오기
		while(rs.next()){
			mem_pw2 = rs.getString("mem_pw");
		}
		//입력한 비밀번호와 DB에서 가져온 비밀번호가 같은지 확인
		if(mem_pw2.equals(mem_pw)){
			sql = "UPDATE MEMBER SET mem_name='" + mem_name + "', mem_pw='" + mem_pw_d+ "' WHERE mem_id='" + mem_id + "'";
			stmt.executeUpdate(sql);
		}
		else{
			out.println("비밀번호가 다릅니다.");
	%>
			<button onclick='history.back()'>이전으로 돌아가기</button>
	<%		
			return;
		}
		stmt.close();
		conn.close();
	%>
<form form method="post" action="Photo_Client.jsp">
	<h1> 회원정보 수정 완료</h1>
	<p> <input type='submit' value='메인 화면으로'></p>
</form>
</body>
</html>