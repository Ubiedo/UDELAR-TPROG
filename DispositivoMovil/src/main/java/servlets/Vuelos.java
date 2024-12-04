package servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

 
import publicar.*;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Servlet implementation class vuelos
 */
@WebServlet("/vuelos/*")
@MultipartConfig
public class Vuelos extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public Vuelos() {
        super();
        // TODO Auto-generated constructor stub
    }
    
    /**
	 * inicializa la sesión si no estaba creada 
	 * @param request 
	 */
	public static void initSession(HttpServletRequest request) {
		HttpSession session = request.getSession();
        if (session.getAttribute("tipo_sesion") == null) {
    		session.setAttribute("tipo_sesion", publicar.TipoSesion.INVITADO);
    		request.getSession().setAttribute("sesion_id", "");
    		request.getSession().setAttribute("az", "false");
    	}
	}
	
	private void processRequest(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		initSession(request);
    	if(((String)request.getSession().getAttribute("sesion_id")).isEmpty()) {
	        response.sendRedirect(request.getContextPath() + "/usuarios/acceso");
	        return;
    	}
    	String path = request.getPathInfo();
    	if (path != null) {
    		switch (path) {
    		case "/":
    			listarvuelos(request, response);
    			break;
    		
    		default:
    			System.out.println("Entrando en cargarVuelo");
    			cargarVuelo(request, response);
        		break;
    		}
    	}else {
			listarvuelos(request, response);
    	}
	}
    
private void cargarVuelo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	
    	publicar.WebServicesService service = new publicar.WebServicesService();
        publicar.WebServices port = service.getWebServicesPort();
        try {
        	String referer = request.getHeader("Referer");
        	if (referer != null) {
        		String vueloN;
        	    if (referer.contains("vuelos/vuelos/")) {
        	    	vueloN = (String) request.getSession().getAttribute("vueloN");
        	    }
        	    else {
        	    	vueloN = request.getPathInfo().substring(8);
        	    	request.getSession().setAttribute("vueloN", vueloN);
        	    }
			DataVuelo vuelo = port.listarDatosVuelo(vueloN);
				    			
			List<String> aerolineasL = port.listarAerolineas().getConjString();
			Set<String> aerolineas = new HashSet<>(aerolineasL);
			String aeroElegida = "";
			for (String aerolinea : aerolineas)
			{
				List<String> vuelosL = port.listarVuelosAerolinea(aerolinea).getConjString();
				Set<String> vuelos = new HashSet<>(vuelosL);
				if (vuelos.contains(URLDecoder.decode(vueloN, StandardCharsets.UTF_8))) {
					aeroElegida = aerolinea;
				}
			}
			String rutaDeVuelo = "";
			
			List<String> rutasL = port.listarRutas().getConjString();
			Set<String> rutas = new HashSet<>(rutasL);
			for (String ruta: rutas) {
				List<String> vuelosRuta = port.vuelosDeRuta(ruta).getConjString();
				if (vuelosRuta.contains(URLDecoder.decode(vueloN, StandardCharsets.UTF_8))) {
					rutaDeVuelo = ruta;
				}
			}
			DataRuta rutaV = port.listarDatosRuta(rutaDeVuelo);
			DataAerolinea aero = (DataAerolinea) port.listarDatosUsuarioNickname(aeroElegida);
			request.setAttribute("ruta", rutaV);
			request.setAttribute("vuelo", vuelo);
			request.setAttribute("nickAero", aeroElegida);
			request.setAttribute("nombreAero", aero.getNombreA());
			
			
			HttpSession sesion = request.getSession();
			TipoSesion tSesion = (TipoSesion) sesion.getAttribute("tipo_sesion");
			String sesion_id = (String) sesion.getAttribute("sesion_id");
			Set<DataClienteVuelo> reservasVuelo = new HashSet<>();
			if (tSesion == TipoSesion.CLIENTE) {
				List<DataClienteVuelo> reservasTotalesL = port.listarReservasUsuario(sesion_id).getConjDataClienteVuelo();
				Set<DataClienteVuelo> reservasTotales = new HashSet<>(reservasTotalesL);
				for (DataClienteVuelo reserva : reservasTotales) {
					if (reserva.getVuelo().equals(vuelo.getNombre())) {
						reservasVuelo.add(reserva);
					}
				}
				
				//REALIZAR CHECK IN
	        	Boolean checkInExitoso = null;
	        	String pedido = request.getParameter("formId");
	        	List<DataReserva> reservas = port.reservasConCheckIn(sesion_id).getConjDataReserva();
	        	boolean noTiene = true;
	        	for(DataReserva res : reservas) {
	        		if(res.getVuelo().equals(vueloN)) {
	        			noTiene = false;
	        		}
	        	}
	        	request.setAttribute("noTiene", noTiene);
	            if ("checkIn".equals(pedido)) {
	            	 checkInExitoso = port.realizarCheckIn(sesion_id, vueloN, LocalDate.now().toString());
	            }
	            String exito;
	            if(checkInExitoso != null) {
	            	exito = checkInExitoso.toString();
	            }else {
	            	exito = "null";
	            }
	            request.setAttribute("checkInExitoso", exito);
			}
			request.setAttribute("reservas", reservasVuelo);
			request.getRequestDispatcher("/WEB-INF/vuelos/vuelo.jsp").forward(request, response);
    		
        	}
        }catch(Exception ex){
        	ex.printStackTrace(); // Para ver el error en consola
        	request.setAttribute("error", "Error al cargar los datos del vuelo");
        }
    	
    }
	
	
    private void listarvuelos(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	
    	publicar.WebServicesService service = new publicar.WebServicesService();
        publicar.WebServices port = service.getWebServicesPort();
        try {
    		
    		List<String> aerolineas = port.listarAerolineas().getConjString();


    		Map<String, List<String>> aeroRutas = new HashMap<>();
    		Map<String, String> aeroNombres = new HashMap<>();
    		Map<String, List<DataVuelo>> rutaVuelos = new HashMap<>();
    		
            

    		for (String aerolinea: aerolineas) {
    			DataAerolinea Daero = (DataAerolinea) port.listarDatosUsuarioNickname(aerolinea);
    			aeroNombres.put(aerolinea, Daero.getNombreA());
    			if (!aeroRutas.containsKey(aerolinea)) {
    				aeroRutas.put(aerolinea, new ArrayList<>());
    			}
    			List<String> rutas =  port.listarRutasDeAerolinea(aerolinea).getConjString();
    			
    			

    			for (String ruta: rutas) {
    				DataRuta r = port.listarDatosRuta(ruta);
    				if (r.getEstado().equals(EstadoRuta.CONFIRMADA)){
    				aeroRutas.get(aerolinea).add(ruta);
    				List<String> vuelos = port.vuelosDeRuta(ruta).getConjString();
    				for (String vuelo: vuelos) {
    					
    					DataVuelo dataV = port.listarDatosVuelo(vuelo);
    					if (!rutaVuelos.containsKey(ruta)) {
    						rutaVuelos.put(ruta, new ArrayList<>());
    					}
    					rutaVuelos.get(ruta).add(dataV);
    				}
    				}
    			}
    		}

    		request.setAttribute("aeroNombres", aeroNombres);
    		request.setAttribute("aeroRutas", aeroRutas);
    		request.setAttribute("rutaVuelos", rutaVuelos);
    		
    		request.getRequestDispatcher("/WEB-INF/vuelos/vuelos.jsp").forward(request, response);
        	
        }catch(Exception ex){
        	ex.printStackTrace(); // Para ver el error en consola
        }
    	
    }
    
    private void crearVuelo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	String ruta = request.getParameter("ruta");
        String nombreVuelo = request.getParameter("nombre-v");
        String fechaVueloS = request.getParameter("nacimiento-c");
        String horaS = request.getParameter("horas");
        String minutosS = request.getParameter("minutos");
        String asientosTuristaS = request.getParameter("asientosTurista");
        String asientosEjecutivoS = request.getParameter("asientosEjecutivo");
        String imagen = "";
        Integer resultadoCrear= 0;
       
        
        Integer asientosTurista = Integer.parseInt(asientosTuristaS);
        Integer asientosEjecutivo = Integer.parseInt(asientosEjecutivoS);
        LocalDate fechaVuelo = LocalDate.parse(fechaVueloS);
        LocalTime duracion = LocalTime.of(Integer.parseInt(horaS), Integer.parseInt(minutosS));
        LocalDate fActual = LocalDate.now();
        
        publicar.WebServicesService service = new publicar.WebServicesService();
        publicar.WebServices port = service.getWebServicesPort();
        
        try {
        	
        	//obtener la imagen
            
            Part filePart = request.getPart("imagen-c"); 
            if (filePart != null && filePart.getSize() > 0) {
                imagen = filePart.getSubmittedFileName(); // Obtiene el nombre del archivo

            }
            Boolean exito = fechaVuelo.isAfter(fActual) || fechaVuelo.isEqual(fActual);
            if (exito) {
            	
    	    	exito = port.altaVuelo(ruta, nombreVuelo, fechaVuelo.toString(), duracion.toString(), asientosTurista, asientosEjecutivo, fActual.toString(), imagen);
    	    	
            	if (!exito) {
            		resultadoCrear = 2;
            	}
       
    	    	
    	    	if (exito && imagen != "") {
    	    		try (InputStream inputStream = filePart.getInputStream();
    			            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream()) {
    			           
    			           byte[] buffer = new byte[1024];
    			           int bytesRead;
    			           
    			           // Leer todo el contenido del archivo en el ByteArrayOutputStream
    			           while ((bytesRead = inputStream.read(buffer)) != -1) {
    			               byteArrayOutputStream.write(buffer, 0, bytesRead);
    			           }
    			           
    			           // Convertir a byte[] y enviar al método postFile solo una vez
    			           byte[] fileData = byteArrayOutputStream.toByteArray();
    			           port.postFile(imagen, fileData);
    			           
    			       } catch (IOException e) {
    			           e.printStackTrace();
    			       }
    	    	}
            }else {
            	resultadoCrear = 1;
            	
            }
           if (resultadoCrear != 0) {
        	   DataVuelo dVuelo = new DataVuelo();
        	   dVuelo.setNombre(nombreVuelo);
        	   dVuelo.setAsientosEjecutivo(asientosEjecutivo);
        	   dVuelo.setAsientosTurista(asientosTurista);
        	   dVuelo.setDuracion(duracion.toString());
        	   dVuelo.setFechaAlta(fActual.toString());
        	   dVuelo.setFecha(fechaVueloS);
        	   dVuelo.setImagen(imagen);
           		request.setAttribute("vuelo", dVuelo);
           		request.setAttribute("ruta", ruta);
           }
        	String aero = (String) request.getSession().getAttribute("sesion_id");
    		List<String> rutasL = port.listarRutasDeAerolinea(aero).getConjString();
    		Set<String> rutas = new HashSet<>(rutasL);
    		request.setAttribute("rutas", rutas);
        	request.setAttribute("resultadoCrear", resultadoCrear);
            request.getRequestDispatcher("/WEB-INF/vuelos/crearVuelo.jsp").forward(request, response);
        	
        }catch(Exception ex) {
        	
        }
    	
    }
    
    private void reservarVuelo(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
    	String cliente = request.getParameter("cliente");
        String vuelo = request.getParameter("vuelo"); 
        String asientoS = request.getParameter("tipoAsiento");
        String equipajeExtraS = request.getParameter("equipajeExtra");
        String formaPago = request.getParameter("formaPago");
        String pasajesString = request.getParameter("pasajes");
        
        publicar.WebServicesService service = new publicar.WebServicesService();
        publicar.WebServices port = service.getWebServicesPort();
        
        try {
        	//agrego pasajes
            Set<DataPasaje> pasajes = new HashSet<DataPasaje>();
            DataCliente DTCliente = (DataCliente) port.listarDatosUsuarioNickname(cliente);
            DataPasaje DPCliente = new DataPasaje();
            DPCliente.setNombre(DTCliente.getNombre());
            DPCliente.setApellido(DTCliente.getApellido());
            pasajes.add(DPCliente);
            if (pasajesString != null && !pasajesString.isEmpty()) {
                String[] pasajesSplit = pasajesString.split(",");
                ArrayList<String> pasajesArray = new ArrayList<>(Arrays.asList(pasajesSplit));
                for (int i=0;i<(pasajesArray.size());i=i+2) {
                    DataPasaje DPpasajero = new DataPasaje();
                    DPpasajero.setNombre(pasajesArray.get(i));
                    DPpasajero.setApellido(pasajesArray.get(i+1));
                    pasajes.add(DPpasajero);
                }
            }
            
            
            Integer equipajeExtra = Integer.parseInt(equipajeExtraS);
            Asiento asiento = Asiento.TURISTA;
            if (asientoS.equals("2"))
            	asiento = Asiento.EJECUTIVO;
            LocalDate fActual = LocalDate.now();
          
            Map<String, DataRutaAsiento> paquetes = (Map<String,DataRutaAsiento>) port.paquetesCanjeables(cliente, vuelo, fActual.toString()).getMapStringDataRutaAsiento();
            Map<Integer, String> codigosPaquetes = new HashMap<Integer, String>();
            Integer codigo = 1;
            for (var entry : paquetes.entrySet()) {
                codigosPaquetes.put(codigo, entry.getKey());
                codigo++;
            }
            
        	Integer resultado = 4; 
        	//0: reserva valida, 1:vuelo ya reservado, 2:asientos insuficientes, 3:paquete invalido, 4:error inesperado
        	if (vuelo != null && cliente != null) {
        		DataColeccion pasajesC = new DataColeccion();
    			List<DataPasaje> p = new ArrayList<>(pasajes);
    			pasajesC.setConjDataPasaje(p);
        		if (formaPago.equals("0")) {
        			
        			resultado = port.reservaDeVuelo(vuelo, cliente, fActual.toString(), asiento, pasajes.size(), equipajeExtra, pasajesC);

        		       			        			
        		}else {
        			Integer codigoPaquete = Integer.parseInt(formaPago);
                	String paquete = codigosPaquetes.get(codigoPaquete);
                	                	
        			resultado = port.reservaDeVueloPaquete(vuelo, cliente, fActual.toString(), asiento, pasajes.size(), equipajeExtra, pasajesC,paquete);	
        		}
        	}
           
        	DataCliente DTUsuario = (DataCliente) port.listarDatosUsuarioNickname(cliente);
    		String nombreCliente = DTUsuario.getNombre();
    		String apellidoCliente = DTUsuario.getApellido();
    		
    		request.setAttribute("paquetes", paquetes);
        	request.setAttribute("resultado", resultado);
        	request.setAttribute("cliente", cliente);
        	request.setAttribute("vuelo", vuelo);
        	request.setAttribute("nombreCliente", nombreCliente);
        	request.setAttribute("apellidoCliente", apellidoCliente);
            request.getRequestDispatcher("/WEB-INF/vuelos/reservarVuelo.jsp").forward(request, response);
        }catch(Exception ex) {
        	
        }
    }


	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		// TODO Auto-generated method stub
		processRequest(request, response);
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	  
	    String formId = request.getParameter("formId");
	    
	    if (formId != null) {
	    	if ("crear-vuelo".equals(formId)){
	    		crearVuelo(request, response); //Crear Vuelo
	    	}else if("checkIn".equals(formId)) {
	    		cargarVuelo(request, response);
	    	}else {
	    		reservarVuelo(request, response);
	    	}
	    } else {
	        System.out.println("formId nulo");
	        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Formulario no reconocido.");
	    }
	}
}
