<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
    <%@page import="publicar.DataUsuario"%>
    <%@page import="publicar.DataCliente"%>
    <%@page import="publicar.DataPasaje"%>
    <%@page import="publicar.DataClienteVuelo"%>
    <%@page import="publicar.DataClientePaquete"%>
    <%@page import="publicar.Documento"%>
   <%@page import="java.util.Set"%>
   <%@page import="java.util.*"%>
   <%@page import="publicar.TipoSesion"%>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!doctype html>
<html lang="es">
  <head>
    <title>Perfil Cliente</title>
    <jsp:include page="/WEB-INF/template/head.jsp" />
    <link rel="stylesheet" href="../static/css/perfil.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/static/js/perfilCliente.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.min.js"></script>
	<style><%@include file="/static/css/perfil.css"%></style>
  </head>
  <body>
    <!-- Header -->
      <jsp:include page="/WEB-INF/template/header.jsp" />
      <!-- Datos -->
        <%
        		//datos usuario
            	DataCliente usuario = (DataCliente) request.getAttribute("perfil");
        		List<publicar.DataUsuario> seguidos = (List<publicar.DataUsuario>) request.getAttribute("seguidos");
        		List<publicar.DataUsuario> seguidores = (List<publicar.DataUsuario>) request.getAttribute("seguidores");
        		Boolean esSeguidor = (Boolean) request.getAttribute("esSeguidor");
        		Boolean esInvitado = request.getSession().getAttribute("tipo_sesion") == publicar.TipoSesion.INVITADO;
        		Boolean esMismoUsuario = (Boolean) request.getAttribute("esMismoUsuario");
        %>
        <script type="text/javascript">
        var cantReservas = <%=request.getAttribute("cantReservas")%>;
    	var indiceReserva = 0;
    	var cantPaquetes = <%=request.getAttribute("cantPaquetes")%>;
    	var indicePaquete = 0;
        function cargarReserva(indice) {
        	if (indice == -1){
        		if (indiceReserva>0){
        			indiceReserva--;
        		}
        		else indiceReserva = 0;
        	}
        	else if (indice == -2){
        		if (indiceReserva < cantReservas-1){
        			indiceReserva++;
        		}
        		else indiceReserva=cantReservas-1;
        	}
        	else{
        		indiceReserva = indice-1;
        	}
        	 // Hacer la solicitud AJAX al servlet
            const xhttp = new XMLHttpRequest();
            xhttp.onload = function () {
                if (xhttp.readyState === XMLHttpRequest.DONE && xhttp.status === 200) {
                    // Actualizar el contenido de la res	erva con la respuesta del servlet
                    document.getElementById("tablaReservas").innerHTML = this.responseText;
                }
            };
            xhttp.open("GET", "${pageContext.request.contextPath}/usuarios/reserva?indice=" + indiceReserva, true);
            xhttp.send();
            }
  
        function cargarPaquete(indice) {
        	if (indice == -1){
        		if (indicePaquete>0){
        			indicePaquete--;
        		}
        		else indicePaquete = 0;
        	}
        	else if (indice == -2){
        		if (indicePaquete < cantPaquetes-1){
        			indicePaquete++;
        		}
        		else indicePaquete=cantPaquetes-1;
        	}
        	else{
        		indicePaquete = indice-1;
        	}
        	 // Hacer la solicitud AJAX al servlet
            const xhttp = new XMLHttpRequest();
            xhttp.onload = function () {
                if (xhttp.readyState === XMLHttpRequest.DONE && xhttp.status === 200) {
                    // Actualizar el contenido de la res	erva con la respuesta del servlet
                    document.getElementById("tablaPaquetes").innerHTML = this.responseText;
                }
            };
            xhttp.open("GET", "${pageContext.request.contextPath}/usuarios/paquete?indice=" + indicePaquete, true);
            xhttp.send();
            }

   	  cargarReserva(1);
   	  cargarPaquete(1);
	</script>

    <div class="container mt-3 rounded mb-3">
        <div class="card">  
          <!--header con imagen-->
          <div class="card-header bg-success-subtle custom-header">
            <div class="row align-items-center">   
             
              <div class="col-md-3">
                <div class="image-container2">
                  <img id="profileImage" src="${pageContext.request.contextPath}/Imagenes?id=<%= usuario.getImagenC() %>" class="object-fit cover border border-imagen rounded-circle float-start img-fluid" alt="foto usuario" style="object-fit: cover;">
                </div>
              </div>
             
              <div class="col-md-9">
              	<h2 class="text-start text-body-emphasis ms-3"><%= usuario.getNombreC() %> <%= usuario.getApellido() %></h2>
              	<h5 class="text-start text-body ms-3">@<%= usuario.getNicknameC() %></h5>
              	
              	<div class="modal fade modal-sm" id="modalSeguidos" aria-hidden="true" aria-labelledby="modalSeguidos" tabindex="-1">
				  <div class="modal-dialog modal-dialog-centered">
				    <div class="modal-content">
				      <div class="modal-header">
				      	<div class="btn-group" role="group" aria-label="Botones">
				        	<button type="button" class="btn btn-primary" id="btnSeguidos">Seguidos</button>
				        	<button class="btn btn-outline-primary" data-bs-target="#modalSeguidores" data-bs-toggle="modal">Seguidores</button>
						</div>
				        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
				      </div>
				      <div class="modal-body">
				      
				      	<c:forEach items="${seguidos}" var="seguido">
					      	<div class="row align-items-center">
					      		<div class="col-md-2">
							        <div class="image-container2" style="width: 60px; height: 60px;">
	        							<c:choose>
                            				<c:when test="${seguido.isEsCliente() == true}">
									            <img src="${pageContext.request.contextPath}/Imagenes?id=${seguido.getImagenC()}" id="imgA" class="object-fit cover border border-imagen rounded-circle float-start img-fluid" style="width: 50px; height: 50px; object-fit: cover;">
									        </c:when>
									        <c:otherwise>
									          	<img src="${pageContext.request.contextPath}/Imagenes?id=${seguido.getImagenA()}" id="imgA" class="object-fit cover border border-imagen rounded-circle float-start img-fluid" style="width: 50px; height: 50px; object-fit: cover;">
									        </c:otherwise>
                                		</c:choose>
			        				</div>				
			        			</div>
			        			<div class="col-md-8 ms-3">
			        				<c:choose>
                           				<c:when test="${seguido.isEsCliente() == true}">
								            <p><a href="${pageContext.request.contextPath}/usuarios/${seguido.getNicknameC()}">${seguido.getNicknameC()}</a></p>
								        </c:when>
								        <c:otherwise>
								          	<p><a href="${pageContext.request.contextPath}/usuarios/${seguido.getNicknameA()}">${seguido.getNicknameA()}</a></p>
								        </c:otherwise>
                               		</c:choose>
			        			</div>
		        			</div>
	        			</c:forEach>
	        			
				      </div>
				    </div>
				  </div>
				</div>
				<div class="modal fade modal-sm" id="modalSeguidores" aria-hidden="true" aria-labelledby="modalSeguidores" tabindex="-1">
				  <div class="modal-dialog modal-dialog-centered">
				    <div class="modal-content">
				      <div class="modal-header">
				        <div class="btn-group" role="group" aria-label="Botones">
				        	<button class="btn btn-outline-primary" data-bs-target="#modalSeguidos" data-bs-toggle="modal">Seguidos</button>
				        	<button type="button" class="btn btn-primary" id="btnSeguidos">Seguidores</button>
						</div>
				        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
				      </div>
				      <div class="modal-body">
						
				      	<c:forEach items="${seguidores}" var="seguidor">
					      	<div class="row align-items-center">
					      		<div class="col-md-2">
							        <div class="image-container2" style="width: 60px; height: 60px;">
	        							<c:choose>
                            				<c:when test="${seguidor.isEsCliente() == true}">
									            <img src="${pageContext.request.contextPath}/Imagenes?id=${seguidor.getImagenC()}" id="imgA" class="object-fit cover border border-imagen rounded-circle float-start img-fluid" style="width: 50px; height: 50px; object-fit: cover;">
									        </c:when>
									        <c:otherwise>
									          	<img src="${pageContext.request.contextPath}/Imagenes?id=${seguidor.getImagenA()}" id="imgA" class="object-fit cover border border-imagen rounded-circle float-start img-fluid" style="width: 50px; height: 50px; object-fit: cover;">
									        </c:otherwise>
                                		</c:choose>
			        				</div>				
			        			</div>
			        			<div class="col-md-8 ms-3">
			        				<c:choose>
                           				<c:when test="${seguidor.isEsCliente() == true}">
								            <p><a href="${pageContext.request.contextPath}/usuarios/${seguidor.getNicknameC()}">${seguidor.getNicknameC()}</a></p>
								        </c:when>
								        <c:otherwise>
								          	<p><a href="${pageContext.request.contextPath}/usuarios/${seguidor.getNicknameA()}">${seguidor.getNicknameA()}</a></p>
								        </c:otherwise>
                               		</c:choose>
			        			</div>
		        			</div>
	        			</c:forEach>
						
				      </div>
				    </div>
				  </div>
				</div>
				
              	
              	<%
              		if ((esSeguidor == false) && (esInvitado == false) && (!esMismoUsuario)) {
				%>
              	<form class="needs-validation" action="${pageContext.request.contextPath}/usuarios/follow" method="post" onsubmit="return handleFormSubmit.call(this, event);" novalidate id="seguir-usuario">
					<button type="button" class="btn" data-bs-target="#modalSeguidos" data-bs-toggle="modal"><%=seguidos.size()%> Seguidos</button>
					<button type="button" class="btn" data-bs-target="#modalSeguidores" data-bs-toggle="modal"><%=seguidores.size()%> Seguidores</button>
				    <button type="submit" id="btnSeguir" class="btn btn-primary ms-3">Seguir</button>
              		<input type="hidden" name="formId" value="seguir-usuario">
              		<input type="hidden" name="usuarioASeguir" value="<%=usuario.getNicknameC()%>">
				</form>
				<%
              		}
				%>
				<%
				    if (esSeguidor) {
				%>
				<form class="needs-validation" action="${pageContext.request.contextPath}/usuarios/unfollow" method="post" onsubmit="return handleFormSubmit.call(this, event);" novalidate id="dejar-seguir-usuario">
					<button type="button" class="btn" data-bs-target="#modalSeguidos" data-bs-toggle="modal"><%=seguidos.size()%> Seguidos</button>
					<button type="button" class="btn" data-bs-target="#modalSeguidores" data-bs-toggle="modal"><%=seguidores.size()%> Seguidores</button>
				    <button type="submit" id="btnDejarDeSeguir" class="btn btn-danger ms-3">Dejar de Seguir</button>
					<input type="hidden" name="formId" value="dejar-seguir-usuario">
              		<input type="hidden" name="usuarioSeguido" value="<%=usuario.getNicknameC()%>">
			    </form>
				<%
				    }
				%>
				<%
				    if ((esInvitado) || (esMismoUsuario)) {
				%>
					<button class="btn" data-bs-target="#modalSeguidos" data-bs-toggle="modal"><%=seguidos.size()%> Seguidos</button>
					<button class="btn" data-bs-target="#modalSeguidores" data-bs-toggle="modal"><%=seguidores.size()%> Seguidores</button>
				<%
				    }
				%>
              	
           	  </div>
              	
            </div>
          </div>
          <!--body del perfil-->
          <div class="card-body custom-body bg-body-tertiary">
            <!--botones de opciones-->
            <ul class="nav nav-tabs " id="myTab" role="tablist">
              <li class="nav-item nav-item-perfil bg-success-subtle">
                <button class="nav-link active rounded" id="info-tab" data-bs-toggle="tab" data-bs-target="#info" type="button" role="tab" aria-controls="info" aria-selected="true">Datos Usuario</button>
              </li>
              <li class="nav-item nav-item-perfil bg-success-subtle">
                <button class="nav-link rounded" id="reservas-tab" data-bs-toggle="tab" data-bs-target="#reservas" type="button" role="tab" aria-controls="reservas" aria-selected="false">Reservas De Vuelo</button>
              </li>
              <li class="nav-item nav-item-perfil bg-success-subtle">
                <button class="nav-link rounded" id="paquetes-tab" data-bs-toggle="tab" data-bs-target="#paquetes" type="button" role="tab" aria-controls="paquetes" aria-selected="false">Paquetes Comprados</button>
              </li>
              <li class="nav-item nav-item-perfil bg-success-subtle">
                <button class="nav-link rounded" id="editar-tab" data-bs-toggle="tab" data-bs-target="#editar" type="button" role="tab" aria-controls="editar" aria-selected="false"><i class="float-end bi-pencil"></i></button>
              </li>
            </ul>
            
            <!-- Contenido de las pestaņas -->
            <div class="tab-content" id="myTabContent">
              <div class="tab-pane fade show active" id="info" role="tabpanel" aria-labelledby="info-tab">
                <!--contenido de datos usuario-->
                <ul class="list-group list-group-hover list-group-striped">
                  <li class="list-group-item"><strong>Mail:</strong> <%= usuario.getEmailC() %></li>
                  <li class="list-group-item" id="contraseņa"><strong>Contraseņa:</strong> <%= usuario.getContrasenhaC() %></li>
                  <li class="list-group-item"><strong><%= usuario.getTipoDocumento() %>: </strong><%= usuario.getNroDocumento() %></li>
                  <li class="list-group-item"><strong>Fecha de Nacimiento:</strong> <%= usuario.getFechaNac() %></li>
                  <li class="list-group-item"><strong>Nacionalidad:</strong> <%= usuario.getNacionalidad() %></li>
                </ul>
              </div>
              <!--contenido de datos Reservas Asociadas-->
              
              <div class="tab-pane fade" id="reservas" role="tabpanel" aria-labelledby="reservas-tab">
              <!--DENTRO DE ACA SE GENERA EL CONTENIDO PARA LAS RESERVAS -->
              <div class="w3-container" id="tablaReservas"></div>	
              </div>
              <!--contenido de Paquetes Comprados w-50 -->
              <div class="tab-pane fade" id="paquetes" role="tabpanel" aria-labelledby="paquetes-tab">
              <!--DENTRO DE ACA SE GENERA EL CONTENIDO PARA LOS PAQUETES -->
                <div class="row" id="tablaPaquetes"></div>
                
              </div>
              <!--contenido de editar-->
            
              <div class="tab-pane fade" id="editar" role="tabpanel" aria-labelledby="editar-tab">
                <form class="needs-validation" id="cliente_edit" method="post" onsubmit="return handleFormSubmit.call(this, event);" enctype="multipart/form-data" novalidate>
                <input type="text" value="modificarCliente" name="formId" hidden="true">
                <div class="form-floating mb-2 mt-3">
                  
                  <input type="text" value="<%=usuario.getNombreC() %>" class="form-control" id="nuevo-nombre" placeholder="Nuevo nombre" name="nuevo-nombre" required>    
                  <label for="nuevo-nombre">Nuevo Nombre:</label>
                  <div class="invalid-feedback">
                    Please choose a username.
                  </div>
                </div>

                <div class="form-floating mb-2 mt-3">
                  <input type="text" value="<%=usuario.getApellido() %>" class="form-control" id="nuevo-apellido" placeholder="Nuevo apellido" name="nuevo-apellido" required>
                  <label for="nuevo-apellido">Nuevo Apellido:</label>
                  <div class="invalid-feedback">
                    Please choose a username.
                  </div>
                </div>

                <div class="form-floating mb-2 mt-3">
                  <input type="text" value="<%=usuario.getContrasenhaC() %>" class="form-control" id="nueva-password" placeholder="Nuevo contraseņa" name="nueva-password" required>
                  <label for="nueva-password">Nueva Contraseņa:</label>
                  <div class="invalid-feedback">
                    Please choose a username.
                  </div>
                </div>
				 <div class="input-group mb-2 mt-3">
                    <label for="imagen-c" class="input-group-text">Imagen</label>
                    <input type="file" class="form-control" id="imagen-c" name="nueva-imagen" accept=".jpg,.gif,.png">
                  </div>
                <div class="row">  
                  <div class="col-sm-3">
                    <select class="form-select form-select-lg" style="margin-top: 1.4rem; font-size: medium;" name="nuevo-tipo-documento" required>
                      <% if(usuario.getTipoDocumento().equals(Documento.PASAPORTE)) { %>
                      	<option value="pasaporte" selected>Pasaporte</option>
                      	<option value="CI">Cedula de Identidad</option>
                      <% } else { %>
                      	<option value="pasaporte">Pasaporte</option>
                      	<option value="CI" selected>Cedula de Identidad</option>
                      <% } %>
                    </select>
                  </div>
                  <div class="col-sm-9">
                    <div class="form-floating mb-2 mt-3">
                      <input type="text" class="form-control"  value="<%=usuario.getNroDocumento() %>" id="nuevo-documento" placeholder="Nuevo documento" name="nuevo-documento" required>
                      <label for="nuevo-nombre">Nuevo Documento:</label>
                      <div class="invalid-feedback">
                        Please choose a username.
                      </div>
                    </div>
                  </div>
                </div>
                
                <div class="form-floating mb-2 mt-3">
                  <input type="date" class="form-control" id="ddob" placeholder="Nueva fecha" name="nueva-fecha">
                  <label for="ddob">Nueva Fecha:</label>
                  <div class="invalid-feedback">
                    Please choose a username.
                  </div>
                </div>

                <div class="form-floating mb-2 mt-3">
                  <input type="text" value="<%= usuario.getNacionalidad() %>" class="form-control" id="nueva-nacionalidad" placeholder="Nueva nacionalidad" name="nueva-nacionalidad" required>
                  <label for="nueva-nacionalidad">Nueva Nacionalidad:</label>
                </div>
             
                <button class="btn btn-success" type="submit">Guardar Cambios</button>
                <script type="text/javascript">
	                function handleFormSubmit(event) {
	                    'use strict';
	                    if (!this.checkValidity()) {
	                        event.preventDefault();
	                        event.stopPropagation();
	                    } else {
	                        return true; // Permitir el envio del formulario si es valido
	                    }
	                    this.classList.add('was-validated');
	                    return false; // Evitar el envio si hay errores
	                }
                </script>
              </form>
              </div>
            
            </div> 
          </div> 
          <!--<div class="card-footer"></div>-->
        </div>
      </div>
<script type="text/javascript">
<%String nickVista = usuario.getNicknameC();
	String nickSesion = (String) request.getSession().getAttribute("sesion_id");
	%>
	if (<%= !nickVista.equals(nickSesion) %>){
	document.getElementById('editar-tab').style.display = 'none';
	document.getElementById('reservas-tab').style.display = 'none';
	document.getElementById('paquetes-tab').style.display = 'none';
	//document.getElementById('cambiar-imagen').style.display = 'none';
	document.getElementById('contraseņa').style.display = 'none';
}
</script>
   	
    <div id="footer">
    <nav class="navbar mb-0 bg-body-secondary" aria-label="breadcrumb" style="padding-left: 1em; padding-right: .5em;">
      <div class="container-fluid">
        <ol class="breadcrumb navbar-text mb-auto">
          <li class="breadcrumb-item nav-link" aria-current="page"><a href="${pageContext.request.contextPath}/home">Home</a></li>
			<li class="breadcrumb-item nav-link" aria-current="page"><a href="${pageContext.request.contextPath}/usuarios">Usuarios</a></li>
          <li class="breadcrumb-item active" aria-current="page"><%= usuario.getNicknameC() %></li>
        </ol>
      </div>
    </nav>
    <jsp:include page="/WEB-INF/template/footer.jsp" />
    </div>
    <script src="${pageContext.request.contextPath}/static/js/validar.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
	<script type="text/javascript"><%@include file="/static/js/validar.js"%></script>
</body>
</html>